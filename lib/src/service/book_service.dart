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
import 'package:light/src/model/selected_list_model.dart';
import 'package:light/src/service/file_service.dart';
import 'package:light/src/model/read_mode.dart';
import 'package:light/src/utils/page_calculator.dart';

class BookService {
  final String name;
  final DB db;
  static SharedPreferences prefs;
  static final Map<String, BookService> _cache = <String, BookService>{};

  factory BookService([String name = 'default']) {
    if (null == prefs) {
      SharedPreferences.getInstance().then((v) {
        prefs = v;
      });
    }
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

  /// 删除书籍
  Future<int> deleteBook(Book book) async {
    return await db
        .rawDelete('DELETE FROM book WHERE title = ?', ['another name']);
  }

  /// 批量删除书籍
  Future<int> deleteBooks(List<Book> books) async {
    int count = 0;
    for (Book book in books) {
      print('for');
      count += await db
              .rawDelete('DELETE FROM book WHERE title = ?', [book.title]) ??
          0;

      prefs.remove(book.title);
    }
    print('count $count');
    return count;
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
  BookDecoder({
    @required this.book,
    this.chapters,
    this.content,
  }) : type = book.bookType;

  /// Book实例
  final Book book;

  /// Book类型
  final BookType type;

  /// 实例缓存
  static Map<Book, BookDecoder> _cache = {};

  /// 全书内容
  String content;

  /// 字节码
  List<int> bytes;

  /// epub实例
  EpubBook epubBook;

  /// text文本最大长度
  int _maxLength = 0;

  int _sectionSize;
  int _maxSectionOffset;

  /// 章节
  List<Chapter> chapters;

  static String html2String(String html) {
    dom.Document document = parse(html);
    dom.Element body = document.body;
//    return hm.convert(body.outerHtml);
//    return body.outerHtml;
    return body.text;
  }

  /// 运行与isolate的初始化方法，获取全书内容
  static void _init(SendPort sendPort) {
//    print('_init@BookDecoder');

    /// 接收外部消息的接口
    ReceivePort receivePort = new ReceivePort();

    /// 向宿主isolate发送sendPort
    sendPort.send(receivePort.sendPort);

    /// 监听消息
    receivePort.listen((msg) async {
      var res;
      Book book;
      try {
        // 如果是'close'，则关闭监听
        if ('close' == msg) {
          receivePort.close();
          return;
        }

        /// 检查消息结构是否合法
        /// 不合法则抛出异常
        ///
        /// msg[0]必须是发送接口
//        print('msg: $msg');

        /// msg[1]必须是Book
        if (msg is Book) {
          book = msg;
        } else {
          sendPort.send(new Exception('消息结构不正确，msg[1]不是Book'));
        }

        // 文件
        File file = new File(book.uri);

        // 整书内容
        String content = '';

        // 章节数据
        List<Chapter> chapters = <Chapter>[];

        // 随机读取
        RandomAccessFile randomAccessFile = file.openSync(mode: FileMode.READ);

        switch (book.bookType) {
          case BookType.txt:
//            print('book type is text');
            String codeType = charsetDetector(randomAccessFile);
//            print('charset is $codeType');
            switch (codeType) {
              case 'gbk':
                sendPort.send('gbk');
                return;
              case 'utf8':
                content =
                    utf8.decode(file.readAsBytesSync(), allowMalformed: true);
                break;
              case 'latin1':
                content = latin1.decode(file.readAsBytesSync());
                break;
              default:
                content = '无内容';
            }
            randomAccessFile.close();
            break;
          case BookType.epub:
//            print('book type is epub');
            EpubBook epub;
            try {
              epub = await EpubReader.readBook(file.readAsBytesSync());
            } catch (e) {
              print('error... $e');
            }
            if (null == epub) {
              print('获取epub失败');
            }
            int i = 0, j = 0;
            int offset = 0;
            epub.Chapters.forEach((EpubChapter chapter) {
//              print('chapter title: ${chapter.Title}');
              String tmp = html2String(chapter.HtmlContent);
//              print('content: $tmp');
              content += tmp;
//              print('content.length = ${content.length}');
              Chapter tmpChapter = new Chapter(
                  id: i,
                  title: chapter.Title,
                  offset: offset,
                  length: tmp.length);
              offset = content.length;
              if (chapter.SubChapters.length > 0) {
                chapter.SubChapters.forEach((EpubChapter subChapter) {
//                  print('sub chapter title: ${subChapter.Title}');
                  i++;
                  String tmp = html2String(chapter.HtmlContent);
//                  print('content: $tmp');
                  content += tmp;
                  tmpChapter.subChapters.add(new Chapter(
                      id: i,
                      title: subChapter.Title,
                      offset: offset,
                      length: tmp.length));
                  offset = content.length;
                });
              }
              chapters.add(tmpChapter);
              i++;
            });
            break;
          case BookType.pdf:
          case BookType.url:
          case BookType.urls:
            content = '不支持该文件类型：${book.uri}';
            break;
        }

        // 发送结果
//        print('chapters: $chapters');
//        print('content.length = ${content.length}');
        res = {'content': content, 'chapters': chapters};
        sendPort.send(res);
      } catch (e) {
        print('_init e: $e');
        throw e;
      }
    });
  }

  /// 内容实例
  ///
  /// 可能在main isolate中调用，也可能在second isolate中调用
  /// 如果txt文件是gbk格式，则从second isolate中返回'gbk'
  /// 如果parentPort不为空切格式为gbk，则向parentPort发送消息，
  /// 好让上级isolate解码gbk文件
  static Future<BookDecoder> init(
      {@required Book book, SendPort parentPort, String text}) async {
//    print('init book decoder');
    try {
      // 如果存在此书籍的实例，则直接返回
      if (_cache.containsKey(book)) {
//      print('已存在bokDecoder');
        return _cache[book];
      }

      // 如果text不为空，则直接返回BookDecoder实例
      if (null != text && text.isNotEmpty) {
        _cache[book] = new BookDecoder(book: book, content: text);
        return _cache[book];
      }

      // 书籍内容
      String content;

      /// 书籍章节
      List<Chapter> chapters;

      // 消息接口
      ReceivePort receivePort = new ReceivePort();

      /// 消息流
      Stream msgStream = receivePort.asBroadcastStream();

      // 创建isolate
      Isolate isolate = await Isolate.spawn(_init, receivePort.sendPort,
          onError: receivePort.sendPort,
          onExit: receivePort.sendPort,
          errorsAreFatal: true);

      /// 用于向isolate发送消息的接口
      SendPort sendPort = await msgStream.first;

      /// 发送计算指令，并返回结果
      sendPort.send(book);
      await for (var res in msgStream) {
        /// 如果是Map，且res['content']存在内容
        /// 则实例化BookDecoder并返回
        if (res is Map) {
          if (res.containsKey('content')) {
            content = res['content'];
          }
          if (res.containsKey('chapters')) {
            chapters = res['chapters'];
          }
        } else if (res is String) {
          /// 如果是字符串，判断是否为'gbk'
          ///
          /// 如果为'gbk'且parentPort不存在
          /// 则直接调用平台代码解析gbk文本
          if ('gbk' == res && null == parentPort) {
            List res = await decodeFromPlatform(book);
            content = res[0];
            chapters = res[1];
//        print('是gbk文件，获取content');
          } else if ('gbk' == res && null != parentPort) {
            /// 如果parentPort存在，则发送'gbk'字符串消息
            content = await sendReceive(parentPort, 'gbk');
          } else {
            throw res;
          }
        } else {
          /// 可能是异常，则抛出
          throw res;
        }

        // 实例化BookDecoder
        _cache[book] =
            new BookDecoder(book: book, content: content, chapters: chapters);

        // 结束isolate
        sendPort.send('close');
        isolate.kill(priority: Isolate.beforeNextEvent);
        print('kill');
        isolate = null;
        msgStream = null;
        receivePort.close();
        receivePort = null;

        return _cache[book];
      }
    } catch (e) {
//      print('init error: $e');
      throw e;
    }
    return null;
  }

  ///获取text文件字节总长度
  ///获取epub文件总章数
  int get maxLength {
    switch (type) {
      case BookType.txt:
      case BookType.epub:
        _maxLength = content?.length ?? 0;
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
  dynamic getSection({int offset, int length, bool raw}) {
//    print('getSection@bookService offset=$offset length=$length');
//    if (sections.containsKey(offset)) return sections[offset];
    String title;
    String text = '';
    bool isLast = false;

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

    switch (book.bookType) {
      case BookType.txt:
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
      case BookType.epub:
//        dom.Document document = parse(chapters[offset].HtmlContent);
//        dom.Element body = document.body;
//        String mdString = hm.convert(body.outerHtml);
//        text = mdString;
//
//        /删除空行
//        text = text.replaceAll(new RegExp(r'[\r\n\t]+'), '\r\n');

        break;
      case BookType.pdf:
      case BookType.url:
      case BookType.urls:
        text = content;
        isLast = true;
        break;
    }
//        ///删除空行
//    text = text.trim();
//    text = '$offset abcdefgABCDEFG';
//        text = text.replaceAll(new RegExp(r'[\r\n\t]+'), '\r\n');
//    print(text);
    if (true == raw) {
      return text;
    }
    Section section =
        new Section(offset: offset, title: title, text: text, isLast: isLast);
    return section;
  }
}

/// 字块
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

  bool get isEmpty => null != text ? text.isEmpty : true;

  @override
  int get hashCode => offset;

  operator ==(sec) => this.offset == sec.offset;

  @override
  String toString() => 'Instance of Section{title: $title, offset: '
      '$offset, length: ${text?.length}, isLast: $isLast';
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
    this.pageSize,
    this.textStyle,
    this.textAlign,
    this.textDirection,
    this.maxLines,
  });

  String key;
  BookDecoder bookDecoder;
  Size pageSize;
  SharedPreferences prefs;

  /// 分页计算器
  static PageCalculator pageCalculator;

  ///内容显示格式
  TextStyle textStyle;
  TextAlign textAlign;
  TextDirection textDirection;
  int maxLines;

//  List<List<int>> records = <List<int>>[];
  List<dynamic> records = <List<int>>[];
  List<List<int>> _tempRecords = <List<int>>[];

  ///用于计算分页的isolate
  static Isolate isolate;

  ///用于接收消息的接口
  static ReceivePort receivePort;
  static Stream receiveStream;
  static ReceivePort errorReceivePort;
  static ReceivePort exitReceivePort;

  ///用于发送消息的接口
  static SendPort sendPort;

  /// 当前是否有计算isolate
  /// 当前key是否处于计算中
  static Map<String, bool> isCalculating = <String, bool>{'default': false};

  ///重置key
  reset({
    @required Size pageSize,
    @required BookDecoder bookDecoder,
    @required textStyle,
    @required textAlign,
    @required textDirection,
    @required maxLines,
  }) async {
//    return;
    print('reset@Record');

    /// 页面尺寸
    this.pageSize = pageSize;

    /// BookDecoder实例
    this.bookDecoder = bookDecoder;

    /// 文字样式
    this.textStyle = textStyle;

    /// 排版样式
    this.textAlign = textAlign;

    /// 文字阅读方向
    this.textDirection = textDirection;

    /// 最大行
    this.maxLines = maxLines;

    /// 当前书籍缓存数据
    Map<String, dynamic> data;

    try {
      // 计算当前分页key
      String _key = sha1
          .convert('$pageSize ${bookDecoder.book.title} ${textStyle.fontSize}'
              ' ${textStyle.height}'
              .codeUnits)
          .toString();
      print('当前分页状态key: $key');
      print('计算得key: $_key');
      if (_key == key) {
        print('key相等，可以直接退出');
        return;
      }
      //key值不相等，尝试获取当前分页key的对应的分页缓存
      print('key值不相等，尝试获取当前分页key的对应的分页缓存');

//      prefs.remove(bookDecoder.book.title);
      try {
        String jsonStr = prefs.getString(bookDecoder.book.title);
        print('jsonStr=$jsonStr');
        print(json.decode(jsonStr));
        if (null == jsonStr)
          throw new Exception(
              '当前书籍不存在SharedPreference数据：${bookDecoder.book.title}');
        data = json.decode(jsonStr);
        // 存在缓存
        print('当前书籍缓存数据: $data');
        if (null != data &&
            data.containsKey('records') &&
            data['records'].containsKey(_key)) {
          //存在分页缓存，替换到当前，并返回
          print('存在分页缓存，替换到当前，并返回');
          key = _key;
          records = data['records'][_key];
          return;
        }
      } catch (e) {
        // 不存在缓存
        print('当前书籍不存在缓存 E: $e');

        /// 检查当前书籍分页是否处于计算中
        /// 在计算则退出
        if (isCalculating['default'] &&
            isCalculating.containsKey(_key) &&
            isCalculating[_key]) {
          // 当前书籍的分页计算进程正在执行，直接返回
          print('当前书籍的分页计算进程正在执行，直接退出');
          return;
        }
      }

      /// 未计算当前书籍
      /// 开启second isolate时先尝试关闭以节约资源
      close();

      // 开启计算进程，修改状态
      print('开启isolate进程');
      isCalculating['default'] = true;
      isCalculating[_key] = true;

      // 消息接收接口
      receivePort = new ReceivePort();

      // 消息流
      receiveStream = receivePort.asBroadcastStream();

      // 异常接口
      errorReceivePort = new ReceivePort();

      // 退出通知接口
      exitReceivePort = new ReceivePort();

      /// 监听错误
      errorReceivePort.listen((e) {
        print('错误消息：$e');
      });

      /// 监听退出通知
      exitReceivePort.listen((e) {
        print('isolate退出通知：$e');
      });

      // 创建second isolate
      isolate = await Isolate.spawn(calculate, receivePort.sendPort,
          onExit: exitReceivePort.sendPort,
          onError: errorReceivePort.sendPort,
          errorsAreFatal: true);

      // 向second isolate发送消息的SendPort
      sendPort = await receiveStream.first;

      // sendPort必须存在
      if (null == sendPort) {
        print('获取second isolate SendPort失败');
        throw new Exception('获取second isolate SendPort失败');
      }

      /// 监听消息
      /// 计算进度、计算结果、gbk事件
      receiveStream.listen((value) {
        /// 如果third isolate要解码的txt文本是gbk格式
        /// 由main isolate解码，并返回文本内容
        if (value is List && value[0] is SendPort && value[1] == 'gbk') {
          print('third isolate解码gbk，main isolate');
          SendPort response = value[0];
          decodeFromPlatform(bookDecoder.book).then((res) {
            response.send(res);
          });
          return;
        }

        // 计算的进度消息
        if (value is Map && 'active' == value['state']) {
          print('进度：${value['process']}%，'
              '页码：${value['number']}，'
              '长度：${value['length']}，'
              '平均长度：${value['eveLength']}，'
              '计算：${value['times']} 次，'
              '总计算：${value['totalTimes']} 次，'
              '平均计算：${value['aveTimes']} 次，'
              '用时：${value['time']} ms，'
              '平均用时 ${value['aveTime']} ms');
        } else if (value is Map && 'done' == value['state']) {
          // 计算完成
          key = _key;
          records = value['records'];
          print('计算完成，共 ${value['length']}字符，共 ${records.length} '
              '页，循环：${value['loopTimes']}次\n'
              '总用时 ${value['time']} s '
              '平均用时 ${value['aveTime']} ms\n'
              '总计算 ${value['times']} 次 '
              '平均计算 ${value['aveTimes']} 次');

          try {
            data = json.decode(prefs.getString(bookDecoder.book.title));
          } catch (e) {
            data = null;
          }
          if (null == data) {
            data = {
              'records': {_key: records}
            };
          } else if (data.containsKey('records')) {
            data['records'][_key] = records;
          }
          try {
            print(data);
            print(json.encode(data));
            prefs.setString(bookDecoder.book.title, jsonEncode(data));
          } catch (e) {
            print('prefs E: $e');
          }

          // 更改计算状态
          isCalculating['default'] = false;
          isCalculating[_key] = false;

          // 关闭isolate
          close();
        } else {
          print('value=$value');
        }
      });

      // 发送数据，开始分页计算
      sendPort.send({
        'book': bookDecoder.book,
        'textStyle': textStyle,
        'textAlign': textAlign,
        'textDirection': textDirection,
        'maxLines': maxLines,
        'pageSize': pageSize
      });
    } catch (e) {
      print('Error@Record: $e ${e.toString()}');
      return;
    }
  }

  /// 计算整书分页数据
  ///
  /// 运行在second isolate中
  static void calculate(SendPort sendPort) {
    print('calculate@Record');

    // sendPort必须存在
    if (null == sendPort) {
      print('获取main isolate SendPort失败');
      throw new Exception('获取main isolate SendPort失败');
    }

    try {
      /// BookDecoder的Future
      Future<BookDecoder> bookDecoderFuture;

      /// 消息接收接口
      ReceivePort receivePort = new ReceivePort();

      /// 向isolate发送SendPort
      sendPort.send(receivePort.sendPort);

      /// 监听消息
      receivePort.listen((msg) {
        print('接收到：$msg');
        if ('close' == msg) {
          receivePort.close();
          return;
        }

        /// 消息必须包含Book实例
        if (msg is! Map || !msg.containsKey('book') || msg['book'] is! Book) {
          print(msg is! Map);
          print(!msg.containsKey('book'));
          print(msg['book'] is! Book);
          throw new Exception('消息格式不正确，无Book');
        }

        /// 获取Future<BookDecoder>
        bookDecoderFuture =
            BookDecoder.init(book: msg['book'], parentPort: sendPort);

        /// 获得BookDecoder，计算分页
        bookDecoderFuture.then((bookDecoder) {
          try {
            print('开始计算分页，总长度：${bookDecoder.maxLength}');
            print('开始计算分页，总长度：${bookDecoder.content.length}');

            /// bookDecoder不能为空
            if (null == bookDecoder) return;

            /// 获取分页计算器实例
            if (null == pageCalculator)
              pageCalculator = new PageCalculator(
                  key: 'book',
                  size: msg['pageSize'],
                  textStyle: msg['textStyle'],
                  textAlign: msg['textAlign'],
                  textDirection: msg['textDirection'],
                  maxLines: msg['maxLines']);

            /// 整书分页数据
            List<List<int>> records = <List<int>>[]; //分页数据

            int length = 400; //长度
            int offset = 0; //偏移
            int index = 0; //页面索引
            int loopTimes = 0; //循环次数
            int times = 0; //计算次数

            // 计算其实时间
            int startTime = new DateTime.now().millisecondsSinceEpoch;
            int time = startTime;

            // 循环分段读取书籍内容
            while ((offset + 1) < bookDecoder.maxLength) {
              print('while');
              loop:
              for (int i = 1; i < 100; i++) {
                print('for');
                loopTimes++;
                if (pageCalculator.load(bookDecoder.getSection(
                        offset: offset, length: length * i, raw: true)) ||
                    (offset + length) >= bookDecoder.maxLength) {
                  index++;
                  List<int> record = [offset, pageCalculator.length];
                  records.add(record); // 添加分页数据
                  offset = record[0] + record[1]; // 更新偏移值
                  length = offset ~/ index + 100; // 更新长度
                  times += pageCalculator.times; // 更新总计算次数
                  // 当前时间
                  int currTime = new DateTime.now().millisecondsSinceEpoch;
                  sendPort.send({
                    'state': 'active',
                    'record': record,
                    'process':
                        (offset / bookDecoder.maxLength * 10000).round() / 100,
                    'number': index,
                    'times': pageCalculator.times,
                    'totalTimes': times,
                    'aveTimes': times / index * 10 ~/ 1 / 10,
                    'time': currTime - time,
                    'totalTime': currTime - startTime,
                    'aveTime': (currTime - startTime) / index * 10 ~/ 1 / 10,
                    'length': record[1],
                    'eveLength': offset / index * 10 ~/ 1 / 10,
                  });
                  time = currTime;
                  pageCalculator.times = 0;
                  break loop;
                }
              }
            }

            /// 计算结束
            sendPort.send({
              'state': 'done',
              'records': records,
              'times': times,
              'aveTimes': times / records.length * 10 ~/ 1 / 10,
              'time': (time - startTime) / 100 ~/ 1 / 10,
              'aveTime': (time - startTime) / records.length * 10 ~/ 1 / 10,
              'loopTimes': loopTimes,
              'length': bookDecoder.maxLength
            });
          } catch (e) {
            /// 计算分页过程中出现异常
            print('计算分页过程中出现异常: $e');
            throw e;
          }
        }).catchError((e) {
          /// 获取BookDecoder时出现异常
          print('获取BookDecoder时出现异常');
          throw e;
        });
      });
    } catch (e) {
      print('calculate方法出现异常: $e');
      throw e;
    }
  }

//  bool containsKey(int key) {
//    if (records.isNotEmpty) return (records.length - 1) >= key;
//    return false;
//  }

  operator [](int index) {
    if (records.isNotEmpty && (records.length - 1) >= index) {
      return records[index];
    }
    if (_tempRecords.isNotEmpty && (_tempRecords.length - 1) >= index) {
      return _tempRecords[index];
    }
    return null;
  }

  operator []=(int index, List<int> record) {
    add(record);
  }

  void add(List<int> record) {
    _tempRecords.add(record);
    print(this.toString());
  }

  @override
  String toString() =>
      records.isEmpty ? _tempRecords.toString() : records.toString();

  void close() {
    print('close@Records');
    isCalculating = {'default': false};
    if (null != isolate) {
//      isolate.pause(isolate.pauseCapability);
      print('kill isolate');
      sendPort?.send('close');
      sendPort = null;
      isolate.kill(priority: Isolate.immediate);
      isolate = null;
      receiveStream = null;
      receivePort?.close();
      receivePort = null;
      exitReceivePort.close();
      exitReceivePort = null;
      errorReceivePort.close();
      errorReceivePort = null;
    }
  }
}

/// 消息发送
Future sendReceive(SendPort sendPort, dynamic args) {
  if (null == sendPort) {
    throw new Exception('sendPort不能为null@sendReceive');
  }
  ReceivePort response = new ReceivePort();
  sendPort.send([response.sendPort, args]);
  return response.first;
}

/// 运行平台代码获取书籍内容
Future<List<dynamic>> decodeFromPlatform(Book book) async {
  var platform = const MethodChannel('light.yotaku.cn/system');
  try {
    String content =
        await platform.invokeMethod('readFile', {'path': book.uri});
    List<Chapter> chapters = <Chapter>[];
    return [content, chapters];
  } on PlatformException catch (e) {
    throw e;
  }
}
