import 'package:flutter/material.dart';

class SelectItem extends StatefulWidget {
  @override
  _SelectItem createState() => new _SelectItem();
}

class _SelectItem extends State<SelectItem> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Text('Select Items'),
      ),
    );
  }
}