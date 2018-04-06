import 'package:flutter/material.dart';

class CustomIndicator extends StatelessWidget {
  CustomIndicator({Key key}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      child: new Center(
          child: const CircularProgressIndicator()
      ),
    );
  }
}