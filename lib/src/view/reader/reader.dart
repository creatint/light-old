import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:light/src/model/book.dart';
import 'page.dart';
import 'menu.dart';
import 'setting_pannel.dart';
import 'package:light/src/model/read_mode.dart';
import 'package:light/src/service/book_service.dart';

class Reader extends StatefulWidget {
  Reader({Key key, @required this.book, this.prefs});

  final Book book;
  final SharedPreferences prefs;

  @override
  ReaderState createState() => new ReaderState();
}

class ReaderState extends State<Reader> {
  final GlobalKey<MenuState> menuKey = new GlobalKey<MenuState>();
  final GlobalKey<PageState> pageKey = new GlobalKey<PageState>();

  ///
  static final BookService bookService = new BookService();

  ///资源服务实例
  Future<BookDecoder> bookDecoderFuture;

  ///阅读主题
  List<ReadMode> readModeList;

  ///当前阅读主题ID
  int currentReadModeId = 20;

  ///内容显示格式
  TextAlign textAlign = TextAlign.justify;
  TextDirection textDirection = TextDirection.ltr;
  double fontSize = 20.0;
  double lineHeight = 1.8;

  TextStyle get textStyle {
    return new TextStyle(
      color: readModeList[currentReadModeId].fontColor,
      fontSize: fontSize,
      height: lineHeight,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
    );
  }

  ///显示菜单
  void showMenu() {
    Navigator
        .push(
            context,
            new PageRouteBuilder(
                opaque: false,
                transitionDuration: const Duration(seconds: 0),
                pageBuilder: (BuildContext context, _, __) {
                  return new Menu(
                    key: new Key(currentReadModeId.toString()),
                    readModeList: readModeList,
                    currentReadModeId: currentReadModeId,
                    handleSettings: handleSettings,
                  );
                }))
        .then((value) {
      if (true == value) {
        Navigator.pop(context);
      }
    });
  }

  ///处理设置
  void handleSettings(Settings setting, dynamic value) {
    print('handleSettings@Reader value=$value');
    switch(setting) {
      case Settings.mode:
        if (value >= 0)
          setState(() {
            currentReadModeId = value;
          });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build@Reader');
    return new Container(
      child: new Stack(
        children: <Widget>[
//          new Text('hwllo ')
          new Page(
            key: pageKey,
            prefs: widget.prefs,
            showMenu: showMenu,
            bookDecoderFuture: bookDecoderFuture,
            bookService: bookService,
            readModeList: readModeList,
            currentReadModeId: currentReadModeId,
            textStyle: textStyle,
            textAlign: textAlign,
            textDirection: textDirection,
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('initState@Reader');
    SystemChrome.setEnabledSystemUIOverlays([]);
    readModeList = bookService.getReadModes();
    bookDecoderFuture = BookDecoder.init(book: widget.book);
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose@Reader');
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
}
