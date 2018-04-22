import 'dart:io';
//import 'dart:ui';

//import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:html2md/html2md.dart' as hm;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

import 'package:epub/epub.dart';
import 'package:light/src/service/db.dart';
import 'package:light/src/model/book.dart';

//import 'package:light/src/service/mock_book.dart';
import 'package:light/src/parts/selected_list_model.dart';
import 'package:light/src/service/file_service.dart';
import 'package:light/src/model/read_mode.dart';
import 'package:light/src/view/reader/content.dart';

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
  BookDecoder({@required this.book, this.chapters, this.catelogs, this.content})
      : type = book.bookType;

  final Book book;
  final BookType type;

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

  List<Catelog> catelogs;
  String cache;

  static Future _init(SendPort sendPort) async {
    print('_init@BookDecoder');
    ReceivePort receivePort = new ReceivePort();
    sendPort.send(receivePort.sendPort);
    await for (var msg in receivePort) {
      var result;
      SendPort response = msg[0];
      Book book = msg[1];
      File file = new File(book.uri);
      try {
        switch (book.bookType) {
          case BookType.txt:
            print('book type is text');
            RandomAccessFile randomAccessFile =
                file.openSync(mode: FileMode.READ);
            String codeType = charsetDetector(randomAccessFile);
            print('charset is $codeType');
            String content;
            switch (codeType) {
              case 'gbk':
                var platform = const MethodChannel('light.yotaku.cn/system');

                try {
                  content = await platform
                      .invokeMethod('readFile', {'path': book.uri});
                } on PlatformException catch (e) {
                  print('readFile@Java Error: ${e.message}');
                }
                print('content=$content');
                break;
              case 'utf8':
                content =
                    utf8.decode(file.readAsBytesSync(), allowMalformed: true);
                break;
              case 'latin1':
                content = latin1.decode(file.readAsBytesSync());
                break;
            }
            randomAccessFile.close();
            result = {'content': content};
            break;
          case BookType.epub:
            print('book type is epub');
            SplayTreeMap<int, EpubChapter> chapters =
                new SplayTreeMap<int, EpubChapter>();
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
//            result = new BookDecoder(
//                book: book,
//                type: type,
//                file: file,
//                epubBook: epub,
//                chapters: chapters,
//                catelogs: catelogs);
            result = {'content': 'epub'};
            break;
          case BookType.pdf:
            break;
          case BookType.url:
            break;
          case BookType.urls:
            break;
        }
        response.send(result);
      } catch (e) {
        print('Decode Error: $e');
        return null;
      }
    }
  }

  ///异步初始化书籍文件
  static Future<BookDecoder> init({@required Book book}) async {
    print('init book decoder');
    ReceivePort receivePort = new ReceivePort();
    await Isolate.spawn(_init, receivePort.sendPort);
    SendPort sendPort = await receivePort.first;
    Map res = await sendReceive(sendPort, book);
    return new BookDecoder(book: book, content: res['content']);
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
//    print('getSection@bookService offset=$offset length=$length');
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
//          print('$offset >= $maxLength offset超出最大值');
          return null;
        }
        if (offset + length >= maxLength) {
//          print('offset + length >= maxLength: '
//              '$offset + $length >= $maxLength');
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
//    print(text);
    Section section =
        new Section(offset: offset, title: title, text: text, isLast: isLast);
//    sections[offset] = section;
//    if (sections.length > sectionsMaxLength) {
//      sections.remove(sections.firstKeyAfter(0));
//    }
    return section;
  }

//  void close() {
//    if (randomAccessFile != null) randomAccessFile.close();
//  }
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

  operator ==(sec) => this.offset == sec.offset;
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
  Record({
    @required this.prefs,
    this.bookDecoder,
    this.media,
    this.textStyle,
    this.textAlign,
    this.textDirection,
    this.maxLines,
  });

  String key;
  BookDecoder bookDecoder;
  Size media;
  SharedPreferences prefs;

  ///内容显示格式
  TextStyle textStyle;
  TextAlign textAlign;
  TextDirection textDirection;
  int maxLines;

  Map<int, List<int>> records = <int, List<int>>{};
  Map<int, List<int>> _tempRecords = <int, List<int>>{};

  ///用于计算分页的isolate
  Isolate isolate;

  ///用于接收消息的接口
  ReceivePort receivePort = new ReceivePort();
  Stream receiveStream;

  ///用于发送消息的接口
  SendPort sendPort;

  /// 当前key是否处于计算中
  Map<String, bool> isCalculating = <String, bool>{};

  ///重置key
  reset({
    @required Size media,
    @required BookDecoder bookDecoder,
    @required textStyle,
    @required textAlign,
    @required textDirection,
    @required maxLines,
  }) async {
    print('reset@Record');
    this.media = media;
    this.bookDecoder = bookDecoder;
    this.textStyle = textStyle;
    this.textAlign = textAlign;
    this.textDirection = textDirection;
    this.maxLines = maxLines;
    try {
      //计算当前分页状态key
      String _key = sha1
          .convert('$media ${textStyle.fontSize} ${textStyle.height}'.codeUnits)
          .toString();

      if (_key != key) {
        //key值不相等，获取当前分页key的对应的分页缓存
        //data = {'record': {key1: records, key2: records, key3: records}}
        Map<String, Map> data;
        String rawStr = prefs.getString(bookDecoder.book.title);
        if (null != rawStr && rawStr.isNotEmpty) {
          data = json.decode(rawStr);
        }

        //检查是否存在当前分页key的缓存
        if (null != data &&
            data.containsKey('record') &&
            data['record'].containsKey(_key)) {
          //存在分页缓存，替换到当前
          key = _key;
          records = data['record'][_key];
        } else {
          //不存在分页缓存，如果当前key不为空，需要重置分页数据、key
          if (null != key) {
            records = null;
            _tempRecords = <int, List<int>>{};
            key = null;
          }

          //如果当前key对应的分页正在计算，则不再计算
          if (true == isCalculating[_key]) {
            return null;
          }
          //标记为计算中
          isCalculating[_key] = true;

          // 生成isolate
          if (null == isolate)
            isolate = await Isolate.spawn(calculate, receivePort.sendPort);

          // 广播接收者
          if (null == receiveStream)
            receiveStream = receivePort.asBroadcastStream();

          // 接收发送者
          if (null == sendPort) sendPort = await receiveStream.first;

          //发送数据，用于计算分页
          sendPort.send({
            'key': _key,
            'book': bookDecoder.book,
            'textStyle': textStyle,
            'textAlign': textAlign,
            'textDirection': textDirection,
            'maxLines': maxLines,
            'media': media
          });
          print('开始计算分页，总长度：${bookDecoder.maxLength}');

          int time1 = new DateTime.now().millisecondsSinceEpoch;
          //监听状态
          receiveStream.listen((value) {
            if ('active' == value['state']) {
//              print('${value['record']}');
              print('进度：${value['process']}%，页码：${value['number']}，'
                  '用时：${value['time']} ms，'
                  '平均用时 ${(value['totalTime'] - time1) / value['number'] * 10 ~/
                  1 / 10} ms');
            } else if ('done' == value['state']) {
              // 计算完成
              key = _key;
              records = value['records'];
              int time2 = new DateTime.now().millisecondsSinceEpoch;
              print('计算完成，共 ${records.length} 页，'
                  '共用时 ${(time2 - time1) / 100 ~/ 10} s\n'
                  '平均用时 ${(time2 - time1) / records.length * 10 ~/ 1 / 10} ms\n'
                  '平均渲染次数 ${value['renderTimes'] / records.length * 10 ~/ 1 /
                  10} 次');
            }
          });
        }
      }
    } catch (e) {
      print('Error@Record: $e ${e.toString()}');
      return null;
    }
  }

  static Future calculate(SendPort sendPort) async {
    print('calculateRecord@Record');
    String key;
    BookDecoder bookDecoder;
    ReceivePort receivePort = new ReceivePort();
    sendPort.send(receivePort.sendPort);
    await for (var msg in receivePort) {
      if (null == msg) continue;

      if (null != msg['book']) {
        bookDecoder = await BookDecoder.init(book: msg['book']);
      }
      Content content = new Content(
          pageNumber: null,
          reverse: false,
          textStyle: msg['textStyle'],
          textAlign: msg['textAlign'],
          textDirection: msg['textDirection'],
          maxLines: msg['maxLines'],
          page: msg['media']);

      Map<int, List<int>> records = <int, List<int>>{}; //分页数据
      int length = 200; //长度
      int offset = 0; //偏移
      int index = 0; //页面索引
      int loopTimes = 0; //循环次数
      Section section; //当前字块
      //获取字块
      Section getSection(int offset, int length) {
        section = bookDecoder.getSection(offset: offset, length: length);
        return section;
      }

      int time = new DateTime.now().millisecondsSinceEpoch;
      int time0 = new DateTime.now().millisecondsSinceEpoch;
      do {
        loop:
        for (int i = 1; i < 100; i++) {
          loopTimes++;
          if (content.load(getSection(offset, length * i))) {
            List<int> record = [offset, content.length];
//            print('calculate record: $record');
            records[index++] = record;
            offset = record[0] + record[1]; //更新偏移值
            int time1 = new DateTime.now().millisecondsSinceEpoch;
            sendPort.send({
              'state': 'active',
              'record': record,
              'process': (offset / bookDecoder.maxLength * 1000).round() / 10,
              'number': index,
              'time': time1 - time,
              'totalTime': time1
            });
            time = new DateTime.now().millisecondsSinceEpoch;
            break loop;
          }
        }
      } while ((offset + length) < bookDecoder.maxLength);
      print('LoopTimes $loopTimes 次');
      print('RenderTimes ${content.renderTimes} 次');
      sendPort.send({
        'state': 'done',
        'records': records,
        'renderTimes': content.renderTimes
      });
    }
  }

  bool containsKey(int key) {
    if (records.isNotEmpty) {
      return records.containsKey(key);
    }
    return _tempRecords.containsKey(key);
  }

  operator [](int index) {
    if (records.isNotEmpty) {
      return records[index];
    }
    return _tempRecords[index];
  }

  operator []=(int index, List<int> record) {
    _tempRecords[index] = record;
  }

  @override
  String toString() => records.toString();

  void close() {
    if (null != isolate) {
      isolate.pause(isolate.pauseCapability);
      isolate.kill();
    }
  }
}

/// 消息发送
Future sendReceive(SendPort sendPort, dynamic args) {
  ReceivePort response = new ReceivePort();
  sendPort.send([response.sendPort, args]);
  return response.first;
}
