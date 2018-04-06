import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:light/src/view/reader/page.dart';
import 'package:light/src/service/book_service.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/view/reader/menu.dart';
import 'package:light/src/view/reader/mask.dart';

///epub、pdf、txt、url_table
class Reader extends StatefulWidget {
  Reader({Key key, @required this.book}) : super(key: key);
  final Book book;

  @override
  _ReaderState createState() => new _ReaderState();
}

class _ReaderState extends State<Reader> {
  GlobalKey _menuKey = new GlobalKey();
  GlobalKey _prevPageKey = new GlobalKey();
  GlobalKey _currPageKey = new GlobalKey();
  GlobalKey _nextPageKey = new GlobalKey();
  static final BookService bookService = new BookService();
  BookDecoder bookDecoder;

  Color backgroundColor = new Color.fromRGBO(241, 236, 225, 1.0);
  Color fontColor = new Color.fromRGBO(38, 38, 38, 1.0);
  double fontSize = 20.0;

//  ByteData data;
  List<int> data;
  bool isShowMenu = false;
  int currPN = 1; //默认页码为1
  Page prevPage; //上一页
  Page currPage; //当前页
  Page nextPage; //下一页

  Page getPrevPage() {
    print('getPrevPage');
    if (1 == currPN) return null;
    nextPage = currPage;
    setState(() {
      currPN--;
      currPage = prevPage;
    });
    prevPage = new Page(
      key: _prevPageKey,
      title: '第一章 啊哈哈无哈啊哈',
      text: bookDecoder.getPrevPage(),
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontColor: fontColor,
    );
    return prevPage;
  }

  Page getNextPage() {
    print('getNextPage');
    prevPage = currPage;
    setState(() {
      currPN++;
      currPage = nextPage;
    });
    nextPage = new Page(
      key: _nextPageKey,
      title: '第一章 哈哈呜哈哈',
      text: bookDecoder.getNextPage(),
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontColor: fontColor,
    );
    return nextPage;
  }

  void handleShowMenu() {
    print('showMenu');
    setState(() {
      isShowMenu = !isShowMenu;
      print(isShowMenu);
    });
    if (isShowMenu) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    } else {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
  }

  Widget getPage() {
    print(MediaQuery.of(context).size);
    List<Page> list = <Page>[];
    currPage = new Page(
        key: _currPageKey,
        title: '第一章 啊哈哈无哈啊哈',
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontColor: fontColor,
        text: bookDecoder.getPage(currPN));
    list.add(currPage);

    return new Stack(
      children: list,
    );
  }

  @override
  void initState() {
    super.initState();
    print('Reader initState');
    bookDecoder = new BookDecoder(book: widget.book);
    SystemChrome.setEnabledSystemUIOverlays([]);
    print(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new GestureDetector(
            child: getPage(),
        ),
        new Mask(
          isShow: false,
          showMenu: handleShowMenu,
          nextPage: getNextPage,
          prevPage: getPrevPage,
        ),
        new Menu(
          key: _menuKey,
          isShow: isShowMenu,
        )
      ],
    ));
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
}
