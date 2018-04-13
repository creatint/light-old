import 'dart:math' as math;
//import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:light/src/model/read_mode.dart';

class Menu extends StatefulWidget {
  Menu(
      {Key key,
      this.isShow: false,
      @required this.handleReadModeChange,
      @required this.currentReadModeId,
      @required this.readModeList})
      : super(key: key);
  final bool isShow;
  final currentReadModeId;
  final ValueChanged<int> handleReadModeChange;
  final List<ReadMode> readModeList;

  @override
  _MenuState createState() => new _MenuState();
}

enum Actions { chapters, modes, darkMode, more }

class _MenuState extends State<Menu> with TickerProviderStateMixin {
  bool isShow = false;
  AnimationController _controller;
  Animation<double> _animation;
  EdgeInsets padding;
  EdgeInsets minimum;
  ThemeData themeData;
  Color iconColor;
  Color backgroundColor;

  ///初始化样式 与 动画
  void initTheme() {
    padding = MediaQuery.of(context).padding;
    minimum = EdgeInsets.zero;
    themeData = Theme.of(context);
    iconColor = themeData.brightness == Brightness.light
        ? Colors.white
        : themeData.accentColor;
    backgroundColor = themeData.brightness == Brightness.light
        ? Colors.black
        : themeData.accentColor;

    if (false == isShow) {
      _controller.forward();
      isShow = true;
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    }
  }

  ///相应按钮
  void _handleMenu(Actions action) {
    print(action);
    switch (action) {
      case Actions.modes:
        handleModes();
        break;
      default:
    }
  }

  void handleModes() {}

  ///退出按钮页面,退出动画
  void handleHideMenu() {
    print('tap middle');
    SystemChrome.setEnabledSystemUIOverlays([]);
    _controller.reverse().then((_) {
      Navigator.pop(context);
    });
  }

  ///
  void handleMenuState() {}

  void handleBookMark() {
    print('add book Mark');
  }

  Widget buildMiddle() {
    return new Expanded(
        child: new GestureDetector(
      child: new Container(
        color: Colors.transparent,
      ),
      onTap: handleHideMenu,
    ));
  }

  Widget buildAppBar() {
    return new SizeTransition(
      sizeFactor: _animation,
      child: new Container(
        padding: new EdgeInsets.only(
          top: math.max(padding.top, minimum.top),
        ),
        color: backgroundColor,
        height: 72.0,
        child: new Row(
          children: <Widget>[
            new IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context, true);
                }),
            new Expanded(child: new Container()),
            new IconButton(
                icon: const Icon(Icons.bookmark), onPressed: handleBookMark)
          ],
        ),
      ),
    );
  }

  ///构建底部操作栏
  Widget buildBottomBar() {
    return new SizeTransition(
      sizeFactor: _animation,
      child: new IconTheme(
        data: new IconThemeData(color: iconColor, size: 24.0),
        child: new Container(
          color: backgroundColor,
          height: 60.0,
          child: new Row(
            children: <Widget>[
              new InkResponse(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new IconButton(
                        icon: const Icon(
                          Icons.list,
                          size: 24.0,
                        ),
                        onPressed: () => _handleMenu(Actions.chapters)),
                  ],
                ),
              ),
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new IconButton(
                      icon: const Icon(Icons.text_fields),
                      onPressed: () => _handleMenu(Actions.modes)),
                ],
              ),
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new IconButton(
                      icon: const Icon(Icons.brightness_2),
                      onPressed: () => _handleMenu(Actions.darkMode)),
                ],
              ),
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => _handleMenu(Actions.more)),
                ],
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
        ),
      ),
    );
  }

  ///构建阅读模式操作面板
  Widget buildReadModePannel() {
    return new Container();
  }

  @override
  void initState() {
    super.initState();
    print('init Menu State');
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _animation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    initTheme();
    return new Scaffold(
      backgroundColor: Colors.transparent,
      body: new IconTheme(
        data: new IconThemeData(color: iconColor),
        child: new Container(
          padding: new EdgeInsets.only(
            left: math.max(padding.left, minimum.left),
            right: math.max(padding.right, minimum.right),
            bottom: math.max(padding.bottom, minimum.bottom),
          ),
          child: new Column(
            children: <Widget>[
              buildAppBar(),
              new Divider(
                height: 1.0,
              ),
              buildMiddle(),
              new Divider(
                height: 1.0,
              ),
              buildBottomBar(),
              buildReadModePannel(),
            ],
          ),
        ),
      ),
    );
  }
}
