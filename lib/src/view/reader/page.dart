import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Page extends StatefulWidget {
  Page(
      {Key key,
      @required this.title,
      @required this.text,
      this.backgroundColor: Colors.white,
      this.fontColor,
      this.fontSize})
      : super(key: key);
  final String title;
  final Future<String> text;
  final Color backgroundColor;
  final Color fontColor;
  final double fontSize;

  @override
  _PageState createState() => new _PageState();
}

class _PageState extends State<Page> {
  @override
  void initState() {
    super.initState();
    print('initState _PageState');
  }

  @override
  Widget build(BuildContext context) {
    print('build _PageState');
    TextStyle titleStyle = Theme
        .of(context)
        .textTheme
        .title
        .copyWith(fontSize: 14.0, color: Theme.of(context).disabledColor);
    TextStyle bodyStyle =
        new TextStyle(color: widget.fontColor, fontSize: widget.fontSize);
    return new Container(
        decoration: new BoxDecoration(color: widget.backgroundColor),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              height: 30.0,
              child: new Row(
                children: <Widget>[
                  new Container(
                    child: new Text(
                      widget.title,
                      style: titleStyle,
                    ),
                  ),
                ],
              ),
            ),
            new Expanded(
                child: new Container(
              child: new FutureBuilder(
                  future: widget.text,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        null != snapshot.data) {
                      return new Text(
                        snapshot.data,
                        style: bodyStyle,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                        maxLines: 24,
                      );
                    } else {
                      return new Container(
                        child: new Center(
                          child: new Text('读取中...'),
                        ),
                      );
                    }
                  }),
            )),
            new Container(
              height: 30.0,
              child: new Row(
                children: <Widget>[
                  new RotatedBox(
                    child: new Icon(Icons.battery_std),
                    quarterTurns: 1,
                  )
                ],
              ),
            )
          ],
        )
//    child: new IconButton(icon: const Icon(Icons.message), onPressed: (){
//      print('messgae');
//    }),
        );
  }
}
