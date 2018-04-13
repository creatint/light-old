//import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Mask extends StatefulWidget {
  Mask({
    Key key,
    this.isShow: true,
  })
      : super(key: key);
  final bool isShow;

  @override
  _MaskState createState() => new _MaskState();
}

class _MaskState extends State<Mask> with TickerProviderStateMixin {
  static AnimationController _controller;
  static Animation<double> _animation;
  Offset start;
  Offset end;

  void _handleHide() {
    print('Mask hide...');
    _controller.forward();
    return;
  }

  @override
  void initState() {
    super.initState();
    print('Mask initState');
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    CurvedAnimation curve =
        new CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _animation = new Tween(begin: 1.0, end: 0.0).animate(curve);
    _handleHide();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Colors.black26;
    return new FadeTransition(
      opacity: _animation,
      child: new Container(
        child: new Column(
          children: <Widget>[
            new Expanded(
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                        flex: 7,
                        child: new Container(
                          decoration: new BoxDecoration(
                              color: backgroundColor,
                              border: new Border(
                                right: new BorderSide(
                                    width: 2.0, color: Colors.black),
                              )),
                          child: new Center(child: new Text(' ')),
                        )),
                    new Expanded(
                        flex: 3,
                        child: new Container(
                          color: backgroundColor,
                          child: new Center(child: new Text(' ')),
                        )),
                  ],
                ),
                flex: 3),
            new Expanded(
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                        flex: 3,
                        child: new Container(
                          color: Colors.black26,
                          child: new Center(
                            child: new Text('上一页'),
                          ),
                        )),
                    new Expanded(
                        flex: 4,
                        child: new Container(
                          decoration: new BoxDecoration(
                              color: backgroundColor,
                              border: new Border.all(
                                  width: 2.0, color: Colors.black)),
                          child: new Center(child: new Text('工具栏')),
                        )),
                    new Expanded(
                        flex: 3,
                        child: new Container(
                          color: backgroundColor,
                          child: new Center(
                            child: new Text('下一页'),
                          ),
                        )),
                  ],
                ),
                flex: 4),
            new Expanded(
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                        flex: 3,
                        child: new Container(
                          color: backgroundColor,
                          child: new Center(child: new Text(' ')),
                        )),
                    new Expanded(
                        flex: 4,
                        child: new Container(
                          decoration: new BoxDecoration(
                              color: backgroundColor,
                              border: new Border(
                                left: new BorderSide(
                                    width: 2.0, color: Colors.black),
                              )),
                          child: new Center(
                            child: new Text('左右划动也可翻页'),
                          ),
                        )),
                    new Expanded(
                        flex: 3,
                        child: new Container(
                          color: backgroundColor,
                          child: new Center(child: new Text(' ')),
                        )),
                  ],
                ),
                flex: 3),
          ],
        ),
      ),
    );
  }
}
