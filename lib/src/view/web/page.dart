import 'package:flutter/material.dart';

class Page extends StatefulWidget {
  @override
  _PageState createState() => new _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Text('Pages'),
      ),
    );
  }
}