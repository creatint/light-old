import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Mask extends StatefulWidget {
  Mask(
      {Key key,
      @required this.showMenu,
      @required this.isShow: true,
      @required this.nextPage,
      @required this.prevPage})
      : super(key: key);
  final bool isShow;
  final VoidCallback showMenu;
  final VoidCallback nextPage;
  final VoidCallback prevPage;

  @override
  _MaskState createState() => new _MaskState();
}

class _MaskState extends State<Mask> with TickerProviderStateMixin {
  static AnimationController _controller;
  static Animation<double> _animation;
  bool horizontalDragging = false;
  Offset start;
  Offset end;

  void _handleShowMenu() {
    if (null != widget.showMenu) widget.showMenu();
  }

  void _handleHide() {
    print('Mask hide...');
    _controller.forward();
    return;
    new Timer(const Duration(milliseconds: 1000), () {
      _controller.forward();
    });
  }

  void _handleHorizontalDragEnd(DragEndDetails value) {
    horizontalDragging = true;
    if (value.velocity.pixelsPerSecond.dx > 0) {
      widget.nextPage();
    } else if (value.velocity.pixelsPerSecond.dx < 0) {
      widget.prevPage();
    }
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
      child: new GestureDetector(
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        child: new Container(
          child: new Column(
            children: <Widget>[
              new Expanded(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                          flex: 7,
                          child: new GestureDetector(
                            onTap: widget.prevPage,
                            child: new Container(
                              decoration: new BoxDecoration(
                                  color: backgroundColor,
                                  border: new Border(
                                    right: new BorderSide(
                                        width: 2.0, color: Colors.black),
                                  )),
                              child: new Center(child: new Text(' ')),
                            ),
                          )),
                      new Expanded(
                          flex: 3,
                          child: new GestureDetector(
                              onTap: widget.nextPage,
                              child: new Container(
                                color: backgroundColor,
                                child: new Center(child: new Text(' ')),
                              ))),
                    ],
                  ),
                  flex: 3),
              new Expanded(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                          flex: 3,
                          child: new GestureDetector(
                            onTap: widget.prevPage,
                            child: new Container(
                              color: Colors.black26,
                              child: new Center(
                                child: new Text('上一页'),
                              ),
                            ),
                          )),
                      new Expanded(
                          flex: 4,
                          child: new GestureDetector(
                            onTap: _handleShowMenu,
                            child: new Container(
                              decoration: new BoxDecoration(
                                  color: backgroundColor,
                                  border: new Border.all(
                                      width: 2.0, color: Colors.black)),
                              child: new Center(child: new Text('工具栏')),
                            ),
                          )),
                      new Expanded(
                          flex: 3,
                          child: new GestureDetector(
                            onTap: widget.nextPage,
                            child: new Container(
                              color: backgroundColor,
                              child: new Center(
                                child: new Text('下一页'),
                              ),
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
                          child: new GestureDetector(
                              onTap: widget.prevPage,
                              child: new Container(
                                color: backgroundColor,
                                child: new Center(child: new Text(' ')),
                              ))),
                      new Expanded(
                          flex: 4,
                          child: new GestureDetector(
                            onTap: widget.nextPage,
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
                            ),
                          )),
                      new Expanded(
                          flex: 3,
                          child: new GestureDetector(
                              onTap: widget.nextPage,
                              child: new Container(
                                color: backgroundColor,
                                child: new Center(child: new Text(' ')),
                              ))),
                    ],
                  ),
                  flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
