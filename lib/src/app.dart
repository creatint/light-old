import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:light/src/service/config.dart';
import 'package:light/src/service/db.dart';
import 'package:light/src/service/initial.dart';
import 'package:light/src/view/home.dart';
import 'package:light/src/view/search/tieba/tieba.dart';
import 'package:light/src/view/search/tieba/detail.dart';
import 'package:light/src/model/tieba_topic.dart';
import 'package:light/src/view/chat/chat_screen.dart';
import 'package:light/src/view/shelf/import_book.dart';

final ThemeData _kGalleryLightTheme = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
);

final ThemeData _kGalleryDarkTheme = new ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
);

class App extends StatefulWidget {
  final SharedPreferences prefs;
  final Config config;
  final DB db;

  App({@required this.config, @required this.prefs, @required this.db});

  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<App> {
  bool _useLightTheme = true;

  @override
  void initState() {
    super.initState();
    print('init app');
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Light',
      debugShowCheckedModeBanner: false,
//      theme: _useLightTheme ? _kGalleryLightTheme : _kGalleryDarkTheme,
      routes: <String, WidgetBuilder>{
//        '/': (BuildContext context) => new ImportBook(
//              key: new Key('start'),
//              isRoot: true,
//              path: '/storage/emulated/0/DuoKan/Downloads/MiCloudBooks',
////                  path: '/storage/emulated/0/DuoKan',
//            ),
        '/': (BuildContext context) => new Home(
              useLightTheme: _useLightTheme,
              prefs: widget.prefs,
              onThemeChanged: (bool value) {
                setState(() {
                  print('set _useLightTheme to $value');
                  _useLightTheme = value;
                });
              },
            ),
//        '/': (BuildContext context) => new Tieba(fname: '爱书的下克上'),
//        '/': (BuildContext context) => new ChatScreen(
//              appAccount: '13244414819',
//              username: 'Creaty',
//            ),
//        '/': (BuildContext context) => new Tieba(fname: '爆肝工程师的异世界狂想曲'),
//        '/': (BuildContext context) => new Detail(
//          topic: new TiebaTopic(title: 'VRchat,科普一下VR平台最火的二次元游戏',
//              url: 'http://tieba.baidu.com/mo/q---0C6E0C5D10B08D2558E1AF076714E837%3AFG%3D1--1-3-0--2--wapp_1521603526919_731/m?kz=5561118240&new_word=&pinf=1_2_60&pn=0&lp=6005',
//              tiebaUrl: 'http://tieba.baidu.com',
//              clickTimes: 12,
//              replyTimes: 384),
//        ),
//        "/": (_) => new WebviewScaffold(
//          url: 'http://tieba.baidu.com/mo/q---0C6E0C5D10B08D2558E1AF076714E837%3AFG%3D1--1-3-0--2--wapp_1521603526919_731/m?kz=5608792899&is_bakan=0&lp=5010&pinf=1_2_0',
//          appBar: new AppBar(
//            title: new Text("Widget webview"),
//          ),
//          withZoom: true,
//        )
      },
    );
  }
}
