import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Profile extends StatefulWidget {
  Profile(
      {@required Key key,
      @required this.useLightTheme,
      @required this.onThemeChanged})
      : super(key: key);
  final bool useLightTheme;
  final ValueChanged<bool> onThemeChanged;

  @override
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Text('Profile'),
      ),
    );
  }
}
