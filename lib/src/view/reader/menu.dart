import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Menu extends StatefulWidget {
  Menu({Key key, @required this.isShow: false}) : super(key: key);
  final bool isShow;

  @override
  _MenuState createState() => new _MenuState();
}

enum Actions { menu }

class _MenuState extends State<Menu> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  void _handleMenu(Actions action) {
    print(action);
  }

  void showMenu() {
    if (widget.isShow) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void addMark() {
    print('addMark');
  }

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _animation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    showMenu();
    final EdgeInsets padding = MediaQuery.of(context).padding;
    final EdgeInsets minimum = EdgeInsets.zero;
    final ThemeData themeData = Theme.of(context);
    Color iconColor = themeData.brightness == Brightness.light
        ? Colors.white
        : themeData.accentColor;
    Color backgroundColor = themeData.brightness == Brightness.light
        ? Colors.black
        : themeData.accentColor;
    return new IconTheme(
      data: new IconThemeData(color: iconColor),
      child: new Container(
        padding: new EdgeInsets.only(
          left: math.max(padding.left, minimum.left),
          right: math.max(padding.right, minimum.right),
          bottom: math.max(padding.bottom, minimum.bottom),
        ),
        child: new Column(
          children: <Widget>[
            new SizeTransition(
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
                          Navigator.pop(context);
                        }),
                    new Expanded(child: new Container()),
                    new IconButton(
                        icon: const Icon(Icons.bookmark), onPressed: addMark)
                  ],
                ),
              ),
            ),
            new Divider(
              height: 1.0,
            ),
            new Expanded(child: new GestureDetector(child: new Container(child: new Center(),), onTap: (){
              showMenu();
            },)),
            new Divider(
              height: 1.0,
            ),
            new SizeTransition(
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
                                  Icons.menu,
                                  size: 24.0,
                                ),
                                onPressed: () => _handleMenu(Actions.menu)),
                          ],
                        ),
                      ),
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new IconButton(
                              icon: const Icon(Icons.text_fields),
                              onPressed: () => _handleMenu(Actions.menu)),
                        ],
                      ),
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new IconButton(
                              icon: const Icon(Icons.brightness_2),
                              onPressed: () => _handleMenu(Actions.menu)),
                        ],
                      ),
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () => _handleMenu(Actions.menu)),
                        ],
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
