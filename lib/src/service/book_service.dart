import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:epub/epub.dart';

import 'package:light/src/service/db.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/service/mock_book.dart';
import 'package:light/src/parts/selected_list_model.dart';
import 'package:light/src/service/file_service.dart';

class BookService {
  final String name;
  final DB db;
  static final Map<String, BookService> _cache = <String, BookService>{};

  factory BookService([String name = 'default']) {
    if (_cache.containsKey(name)) {
      return _cache[name];
    } else {
      _cache[name] = new BookService._internal(name, new DB());
      return _cache[name];
    }
  }

  BookService._internal(this.name, this.db);

  Future<List<Book>> getBooks([String word]) async {
    if (null == db) {
      throw new Exception('db is null');
    }
    List<Map> list = await db.query('book');
    print(list);
    return list.map((Map map) => new Book.fromMap(map: map)).toList();
  }

  Future<int> createBook(Book book) async {
    if (null == db) {
      throw new Exception('db is null');
    }
    List<Map> list = await db.query('book', where: 'uri = "${book.uri}"');
    if (null == list || list.isEmpty) {
      print(book.getMap());
      int id = await db.insert('book', book.getMap());
      print('id: $id');
      return id;
    } else
      return -1;
  }

  Future<int> createBooks(List<Book> books) async {
    int num = 0;
    for (Book book in books) {
      if (await createBook(book) >= 0) {
        num++;
      }
    }
//    books.forEach((Book book) async {
//      if (await createBook(book) >= 0) {
//        num++;
//      }
//    });
    print('return createBooks');
    return new Future.value(num);
  }

  ///导入本地书籍
  void addLocalBook(String path) {}

  ///批量导入本地书籍
  Future<int> addLocalBooks(SelectedListModel<FileSystemEntity> list) {
    List<Book> books = <Book>[];
    list.forEach((entity) {
      books.add(new Book.fromEntity(entity: entity));
    });
//    print(books);
    return createBooks(books);
  }
}

class BookDecoder {
  BookDecoder({@required this.book}) : file = new File(book.uri) {
    maxPN = file.lengthSync()~/byteSize;
  }

  final Book book;
  RandomAccessFile randomAccessFile;
  int byteSize = 1110;
  int position = 0;
  int currPN = 1;
  int maxPN;
  Future<String> prevContent;
  Future<String> currContent;
  Future<String> nextContent;

  File file;
  List<String> chapters;

  void decode() async {
    switch (book.bookType) {
      case BookType.txt:
        decodeText();
        break;
      case BookType.epub:
        decodeEpub();
        break;
      case BookType.pdf:
        break;
      case BookType.url:
        break;
      case BookType.urls:
        break;
    }
  }

  decodeText() {}

  void decodeEpub() async {
    List<int> bytes = await file.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);
  }

  Future<String> getContent(int pn) async {
    if (pn < 1) return null;
    if (pn > maxPN) return null;
    print('flag0');
    print('getContent pn=$pn');
    print(book.bookType);
    print('getContent pn=$pn type=${book.bookType.toString()}');
    print('getContent pn=$pn type=${book.bookType}');
    String text = '';
    switch (book.bookType) {
      case BookType.txt:
        print('getContent is text');
        if (null == randomAccessFile) {
          randomAccessFile = file.openSync(mode: FileMode.READ);
        }
        randomAccessFile.setPositionSync((pn - 1) * byteSize);
        List<int> bytes = randomAccessFile.readSync(byteSize);
        text = utf8.decode(bytes);
        break;
      case BookType.epub:
        break;
      case BookType.pdf:
        break;
      case BookType.url:
        break;
      case BookType.urls:
        break;
    }
    return text;
  }

  Future<String> getPage(int pn) {
    print('getPage pn=$pn currPN=$currPN');
    if (pn == currPN) {
      print('flag1');
      if (null == currContent) {
        print('flag2');
        currContent = getContent(pn);
      }
    } else if (pn == (currPN + 1)) {
      currPN = pn;
      prevContent = currContent;
      currContent = nextContent;
      nextContent = getContent(pn + 1);
    } else if (pn == (currPN - 1)) {
      currPN = pn;
      nextContent = currContent;
      currContent = prevContent;
      prevContent = getContent(pn - 1);
    } else {
      currPN = pn;
      prevContent = getContent(pn - 1);
      currContent = getContent(pn);
      nextContent = getContent(pn + 1);
    }
    return currContent;
  }

  Future<String> getPrevPage() {
    return prevContent;
  }

  Future<String> getNextPage() {
    return nextContent;
  }
}

///判断文件是否是电子书资源
bool isBook(dynamic data) {
  if (data is FileType) {
    switch (data) {
      case FileType.TEXT:
      case FileType.EPUB:
      case FileType.PDF:
        return true;
      default:
        return false;
    }
  } else if (data is FileSystemEntity) {
    return isBook(getType(data));
  }
  return false;
}
