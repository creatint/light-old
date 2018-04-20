import 'dart:io';

//import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:html2md/html2md.dart' as hm;

import 'package:epub/epub.dart';
import 'package:light/src/service/db.dart';
import 'package:light/src/model/book.dart';

//import 'package:light/src/service/mock_book.dart';
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
    List<Map<String, dynamic>> list = await db.query('book');
    return list
        .map((Map<String, dynamic> map) => new Book.fromMap(map: map))
        .toList();
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
          backgroundColor: const Color(0xffffffff)),
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
          backgroundColor: const Color(0xffcdd6ba)),
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
          imageUri: 'assets/background/bg1.png'),
      new ReadMode(
          id: 11,
          type: ReadModeType.texture,
          fontColor: const Color(0xff3a3931),
          imageUri: 'assets/background/bg2.png'),
      new ReadMode(
          id: 12,
          type: ReadModeType.texture,
          fontColor: const Color(0xff3a3931),
          imageUri: 'assets/background/bg3.png'),
      new ReadMode(
          id: 13,
          type: ReadModeType.texture,
          fontColor: const Color(0xff3a3129),
          imageUri: 'assets/background/bg4.png'),
      new ReadMode(
          id: 14,
          type: ReadModeType.texture,
          fontColor: const Color(0xffb5b6b5),
          imageUri: 'assets/background/bg5.png'),

      //背景图片
      new ReadMode(
          id: 15,
          type: ReadModeType.image,
          fontColor: const Color(0xff1b310e),
          imageUri: 'assets/background/bg6.png'),
      new ReadMode(
          id: 16,
          type: ReadModeType.image,
          fontColor: const Color(0xff3a3129),
          imageUri: 'assets/background/bg7.jpg'),
      new ReadMode(
          id: 17,
          type: ReadModeType.image,
          fontColor: const Color(0xff5e432e),
          imageUri: 'assets/background/bg8.png'),
      new ReadMode(
          id: 18,
          type: ReadModeType.image,
          fontColor: const Color(0xff801634),
          imageUri: 'assets/background/bg9.png'),
      new ReadMode(
          id: 19,
          type: ReadModeType.image,
          fontColor: const Color(0xffd6a68d),
          imageUri: 'assets/background/bg10.png'),
      new ReadMode(
          id: 20,
          type: ReadModeType.image,
          fontColor: const Color(0xff5e432e),
          imageUri: 'assets/background/bg11.png'),
    ];
    return list;
  }
}

class BookDecoder {
  BookDecoder(
      {@required this.book,
      @required this.type,
      @required this.file,
      this.randomAccessFile,
      this.epubBook,
      this.chapters,
      this.catelogs,
      this.content});

  final Book book;
  final BookType type;
  final File file;
  final RandomAccessFile randomAccessFile;
  static const platform = const MethodChannel('light.yotaku.cn/system');
  String content; //全部内容
  List<int> bytes;
  EpubBook epubBook;
  int byteSize = 1110; //每页字节数
  int position = 0; //起始位置
  int currPN = 1; //当前页码
  int maxPN; //最大页码
  int _maxLength = 0; //text文本最大长度
  int _sectionSize;
  int _maxSectionOffset;
  Future<String> prevSection;
  Future<String> currSection;
  Future<String> nextSection;
  SplayTreeMap<int, EpubChapter> chapters;
  SplayTreeMap<int, Section> sections = new SplayTreeMap<int, Section>();

//  int sectionsMaxLength = 20;
  List<Catelog> catelogs;
  String cache;

  ///异步初始化书籍文件
  static Future<BookDecoder> init({@required Book book}) async {
    print('init book decoder');
    File file = new File(book.uri);
    try {
      switch (book.bookType) {
        case BookType.txt:
          print('book type is text');
          BookType type = BookType.txt;
          RandomAccessFile randomAccessFile =
              file.openSync(mode: FileMode.READ);
          String codeType = charsetDetector(randomAccessFile);
          print('charset is $codeType');
          List<int> bytes = file.readAsBytesSync();
          String content;
          try {
            switch (codeType) {
              case 'gbk':
//                content = 'gbk';
                content = await platform
                    .invokeMethod('decodeGbkFile', {'path': book.uri});
                content +=content += content += content+= content+= content+= content;
                break;
              case 'utf8':
                content = utf8.decode(bytes, allowMalformed: true);
                break;
              case 'latin1':
                content = latin1.decode(bytes);
                break;
            }
          } catch (e) {
            print('Error: $e');
          }
//          String content = file.readAsStringSync(encoding: latin1);
//          String content = file.readAsStringSync(encoding: utf8);
//          String content = file.readAsStringSync(encoding: gb2312);
          return new BookDecoder(
              book: book,
              type: type,
              file: file,
              content: content,
              randomAccessFile: randomAccessFile);
          break;
        case BookType.epub:
          print('book type is epub');
          SplayTreeMap<int, EpubChapter> chapters =
              new SplayTreeMap<int, EpubChapter>();
          BookType type = BookType.epub;
          List<int> bytes = file.readAsBytesSync();
          EpubBook epub;
          List<Catelog> catelogs = <Catelog>[];
          try {
            epub = await EpubReader.readBook(bytes);
          } catch (e) {
            print('error... $e');
          }
          if (null == epub) {
            print('获取epub失败');
          }
          int i = 0;
          epub.Chapters.forEach((EpubChapter chapter) {
            chapters[i] = chapter;
            Catelog catelog = new Catelog(title: chapter.Title, offset: i);
            if (chapter.SubChapters.length > 0) {
              chapter.SubChapters.forEach((EpubChapter subChapter) {
                i++;
                chapters[i] = subChapter;
                catelog.subCatelogs
                    .add(new Catelog(title: subChapter.Title, offset: i));
              });
            }
            catelogs.add(catelog);
            i++;
          });
          return new BookDecoder(
              book: book,
              type: type,
              file: file,
              epubBook: epub,
              chapters: chapters,
              catelogs: catelogs);
          break;
        case BookType.pdf:
          break;
        case BookType.url:
          break;
        case BookType.urls:
          break;
      }
      return null;
    } catch (e) {
      print('error!!!!: $e');
      return null;
    }
  }

  ///获取text文件字节总长度
  ///获取epub文件总章数
  int get maxLength {
    switch (type) {
      case BookType.txt:
//        _maxLength = randomAccessFile.lengthSync();
        _maxLength = content?.length ?? 0;
        break;
      case BookType.epub:
        _maxLength = chapters.length;
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

  ///txt：字块最大偏移数
  int get maxSectionOffset {
    if (null != _maxSectionOffset) {
      return _maxSectionOffset;
    }
    switch (type) {
      case BookType.txt:
        _maxSectionOffset = (maxLength / _sectionSize).ceil();
        break;
      case BookType.epub:
        _maxSectionOffset = chapters.length;
        break;
      case BookType.pdf:
        break;
      case BookType.url:
        break;
      case BookType.urls:
        break;
    }
    return _maxSectionOffset;
  }

  ///获取字块
  Section getSection({int offset, int length}) {
    print('getSection@bookService offset=$offset length=$length');
    if (sections.containsKey(offset)) return sections[offset];
    String title;
    String text = '';
    bool isLast = false;
    switch (book.bookType) {
      case BookType.txt:
        if (!(offset >= 0) || !(length > 0)) {
          return null;
        }
        if (offset >= maxLength) {
          return null;
        }
        if (offset + length >= maxLength) {
          text = content.substring(offset, maxLength);
          isLast = true;
        } else {
          text = content.substring(offset, offset + length);
        }
//        randomAccessFile.setPositionSync(offset * length);
//        randomAccessFile.setPositionSync(offset);
//        bytes = randomAccessFile.readSync(length);
//        text = utf8.decode(bytes);
//        if (null != cache) {
//          text = cache + text;
//          cache = null;
//        }
//        ///优化缩进
//        text = text.replaceAll(new RegExp(r'[ ]{4,}'),'    ');
//        if (new RegExp(r'[ ]+([^\r\n\t]+)$', multiLine: false).hasMatch(text)) {
//          print('match: ' +
//              new RegExp(r'[ ]+([^\s]+)$')
//                  .firstMatch(text)
//                  ?.group(1)
//                  .toString());
//          text = text.replaceAllMapped(new RegExp(r'[^\r\n\t]*[ ]+([^\s]+)$', multiLine: false), (match) {
//            if (null != match) {
//              cache = match.group(0);
//              return '';
//            }
//          });
//        }
        break;
      case BookType.epub:
        if (offset >= chapters.length) {
          return null;
        }
        title = chapters[offset].Title;
        dom.Document document = parse(chapters[offset].HtmlContent);
        dom.Element body = document.body;
        String mdString = hm.convert(body.outerHtml);
        text = mdString;

        ///删除空行
        text = text.replaceAll(new RegExp(r'[\r\n\t]+'), '\r\n');

        break;
      case BookType.pdf:
        break;
      case BookType.url:
        break;
      case BookType.urls:
        break;
    }
//        ///删除空行
//    text = text.trim();
//    text = '$offset abcdefgABCDEFG';
//        text = text.replaceAll(new RegExp(r'[\r\n\t]+'), '\r\n');
    print(text);
    Section section =
        new Section(offset: offset, title: title, text: text, isLast: isLast);
//    sections[offset] = section;
//    if (sections.length > sectionsMaxLength) {
//      sections.remove(sections.firstKeyAfter(0));
//    }
    return section;
  }

  void close() {
    if (randomAccessFile != null) randomAccessFile.close();
  }
}

///目录，subCatelog
class Catelog {
  Catelog({@required this.title, @required this.offset});

  final String title;
  final int offset;
  List<Catelog> subCatelogs = <Catelog>[];

  int get count => subCatelogs.length;
}

class Section {
  Section(
      {this.offset,
      this.title,
      @required this.text,
      this.imageUris,
      this.isLast: false});

  final int offset;
  final String title;
  String text;
  final List<String> imageUris;
  final bool isLast;

  bool get isNotEmpty => null != text ? text.isNotEmpty : false;

  bool get IsEmpty => null != text ? text.isEmpty : true;

  @override
  int get hash => offset;

  operator == (sec) => this.offset == sec.offset;
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



///阅读记录
///页面Size、fontSize、lineHeight
class Record {
  Record({this.key, this.height, this.width, this.fontSize, this.lineHeight});

  String key;

  double height;
  double width;
  double fontSize;
  double lineHeight;

  Map<int, Map<int, int>> _records = <int, Map<int, int>>{};

  bool containsKey(int key) => _records.containsKey(key);

  operator [](int index) => _records[index];

  @override
  String toString() => _records.toString();
}
