import 'package:flutter/material.dart';

class SettingList extends StatefulWidget {
  @override
  _SettingListState createState() => _SettingListState();
}

class _SettingListState extends State<SettingList> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('阅读设置'),
      ),
      body: new Container(
        child: new Text('settings'),
      ),
    );
  }
}
