import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:epub/epub.dart';
import 'package:light/src/service/db.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/service/mock_book.dart';
import 'package:light/src/parts/selected_list_model.dart';
import 'package:light/src/service/file_service.dart';
import 'package:light/src/model/read_mode.dart';

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
    return createBooks(books);
  }

  List<ReadMode> getReadModes() {
    List<ReadMode> list;
//    List<Map> res = await db.query('read_mode');
//    res.forEach((Map map) {
//      list.add(new ReadMode.fromMap(map));
//    });
    list = <ReadMode>[
      //纯色
      new ReadMode(
          id: 0,
          type: ReadModeType.color,
          fontColor: const Color(0xff424142),
          backgroundColor: const Color(0xffffff)),
      new ReadMode(
        id: 1,
        type: ReadModeType.color,
        fontColor: const Color(0xff424142),
        backgroundColor: const Color(0xfff1ece1),
      ),
      new ReadMode(
        id: 2,
        type: ReadModeType.color,
        fontColor: const Color(0xff424142),
        backgroundColor: const Color(0xffe5d7bd),
      ),
      new ReadMode(
          id: 3,
          type: ReadModeType.color,
          fontColor: const Color(0xff424142),
          backgroundColor: const Color(0xffdcd3c4)),
      new ReadMode(
          id: 4,
          type: ReadModeType.color,
          fontColor: const Color(0xff424142),
          backgroundColor: const Color(0xffa4a4a4)),
      new ReadMode(
          id: 5,
          type: ReadModeType.color,
          fontColor: const Color(0xff3a3931),
          backgroundColor: const Color(0xff0e9cb)),
      new ReadMode(
          id: 6,
          type: ReadModeType.color,
          fontColor: const Color(0xff313d31),
          backgroundColor: const Color(0xffc8edcc)),
      new ReadMode(
          id: 7,
          type: ReadModeType.color,
          fontColor: const Color(0xffadbab5),
          backgroundColor: const Color(0xff35514b)),
      new ReadMode(
          id: 8,
          type: ReadModeType.color,
          fontColor: const Color(0xffadaeb5),
          backgroundColor: const Color(0xff283448)),
      new ReadMode(
          id: 9,
          type: ReadModeType.color,
          fontColor: const Color(0xff5b5b5b),
          backgroundColor: const Color(0xff000000)),

      //纹理图片
      new ReadMode(
          id: 10,
          type: ReadModeType.texture,
          fontColor: const Color(0xff423d3a),
          image_uri: 'assets/background/bg1.png'),
      new ReadMode(
          id: 11,
          type: ReadModeType.texture,
          fontColor: const Color(0xff3a3931),
          image_uri: 'assets/background/bg2.png'),
      new ReadMode(
          id: 12,
          type: ReadModeType.texture,
          fontColor: const Color(0xff3a3931),
          image_uri: 'assets/background/bg3.png'),
      new ReadMode(
          id: 13,
          type: ReadModeType.texture,
          fontColor: const Color(0xff3a3129),
          image_uri: 'assets/background/bg4.png'),
      new ReadMode(
          id: 14,
          type: ReadModeType.texture,
          fontColor: const Color(0xffb5b6b5),
          image_uri: 'assets/background/bg5.png'),

      //背景图片
      new ReadMode(
          id: 15,
          type: ReadModeType.image,
          fontColor: const Color(0xff1b310e),
          image_uri: 'assets/background/bg6.png'),
      new ReadMode(
          id: 16,
          type: ReadModeType.image,
          fontColor: const Color(0xff3a3129),
          image_uri: 'assets/background/bg7.jpg'),
      new ReadMode(
          id: 17,
          type: ReadModeType.image,
          fontColor: const Color(0xff5e432e),
          image_uri: 'assets/background/bg8.png'),
      new ReadMode(
          id: 18,
          type: ReadModeType.image,
          fontColor: const Color(0xff801634),
          image_uri: 'assets/background/bg9.png'),
      new ReadMode(
          id: 19,
          type: ReadModeType.image,
          fontColor: const Color(0xffd6a68d),
          image_uri: 'assets/background/bg10.png'),
      new ReadMode(
          id: 20,
          type: ReadModeType.image,
          fontColor: const Color(0xff5e432e),
          image_uri: 'assets/background/bg11.png'),
    ];
    return list;
  }
}

class BookDecoder {
  BookDecoder({@required this.book, @required int sectionSize})
      : file = new File(book.uri),
        _sectionSize = sectionSize;

  final Book book;
  RandomAccessFile randomAccessFile;
  int byteSize = 1110; //每页字节数
  int position = 0; //起始位置
  int currPN = 1; //当前页码
  int maxPN; //最大页码
  int _maxLength; //text文本最大长度
  final int _sectionSize;
  int _maxSectionOffset;
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

  int getMaxLength() {
    return randomAccessFile.lengthSync();
  }

  void initBook() {}

  int get maxLength {
    switch (book.bookType) {
      case BookType.txt:
        if (null == randomAccessFile) {
          randomAccessFile = file.openSync(mode: FileMode.READ);
          _maxLength = randomAccessFile.lengthSync();
        }
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
    return _maxLength;
  }

  int get maxSectionOffset {
    if (null != _maxSectionOffset) {
      return _maxSectionOffset;
    }
    _maxSectionOffset = (maxLength / _sectionSize).ceil();
    return _maxSectionOffset;
  }

  ///获取字块
  String getSection({int offset, int length}) {
//  print('bookService getSection');
    String text = '';
    switch (book.bookType) {
      case BookType.txt:
        if (null == randomAccessFile) {
          randomAccessFile = file.openSync(mode: FileMode.READ);
          _maxLength = randomAccessFile.lengthSync();
        }
        if (offset * length >= maxLength) {
          return null;
        }
        randomAccessFile.setPositionSync(offset * length);
        List<int> bytes = randomAccessFile.readSync(length);
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

  void close() {
    randomAccessFile.close();
    file = null;
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
