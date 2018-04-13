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

  ///资源服务实例
  static final BookService bookService = new BookService();

  ///阅读主题
  List<ReadMode> readModeList;

  ///当前阅读主题ID
  int currentReadModeId = 2;

  ///显示菜单
  void showMenu() {
    Navigator.push(context, new PageRouteBuilder(
            opaque: false,
            transitionDuration: const Duration(seconds: 0),
            pageBuilder: (BuildContext context, _, __) {
              return new Menu(
                key: menuKey,
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

  void handleSettings(Settings setting, dynamic value) {
    print('handleSettings value=$value');
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Stack(
        children: <Widget>[new Page(showMenu: showMenu)],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('initState@Reader');
    SystemChrome.setEnabledSystemUIOverlays([]);
    readModeList = bookService.getReadModes();
  }


  @override
  void dispose() {
    super.dispose();
    print('dispose@Reader');
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
}
