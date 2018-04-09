import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:light/src/view/custom_page_route.dart';
import 'package:light/src/view/reader/page.dart';
import 'package:light/src/service/book_service.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/view/reader/menu.dart';
import 'package:light/src/view/reader/mask.dart';
import 'package:light/src/model/read_mode.dart';

///epub、pdf、txt、url_table
class Reader extends StatefulWidget {
  Reader({Key key, @required this.book, @required this.prefs})
      : super(key: key);
  final Book book;
  final SharedPreferences prefs;

  @override
  _ReaderState createState() => new _ReaderState();
}

class _ReaderState extends State<Reader> {
  GlobalKey _menuKey = new GlobalKey();
  GlobalKey _currPageKey = new GlobalKey();
  int sectionSize = 200;
  static final BookService bookService = new BookService();
  BookDecoder bookDecoder;
  List<ReadMode> readModeList;
  int currentReadModeId;
  bool isShowMenu = false;

  ///处理显隐菜单事件
  void handleShowMenu() {
    print('showMenu');
    Navigator
        .push(
            context,
            new PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) {
                  return new Menu(
                    key: _menuKey,
                    isShow: isShowMenu,
                    readModeList: readModeList,
                    currentReadModeId: currentReadModeId,
                    handleReadModeChange: handleReadModeChange,
                  );
                }))
        .then((value) {
      if (true == value) {
        Navigator.pop(context);
      }
    });
  }

  ///处理主题模式改变事件
  void handleReadModeChange(int id) {
    print('handleReadModeChange id=$id');
    if (id >= 0) {
      widget.prefs.setInt('readModeId', id);
    }
    setState(() {
      print('改变了样式主题 id=$id');
      currentReadModeId = id;
    });
  }

  int getInitialPageNumber() {
    return 1;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    print('Reader initState');
    bookDecoder = new BookDecoder(book: widget.book, sectionSize: sectionSize);
    readModeList = bookService.getReadModes();
    currentReadModeId = widget.prefs.getInt('readModeId') ?? 16;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new Page(
            key: _currPageKey,
            book: bookDecoder,
            initialPageNumber: getInitialPageNumber(),
            prefs: widget.prefs,
            currentReadModeId: currentReadModeId,
            readModeList: readModeList,
            handleShowMenu: handleShowMenu,
            sectionSize: sectionSize),
//        new Mask(
//          isShow: false,
//        ),
      ],
    ));
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
}
