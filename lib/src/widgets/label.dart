import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  Label({Key key, this.title, this.style, this.padding});

  final String title;
  final TextStyle style;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: title != null
            ? new Text(
          title,
          style: style ??
              Theme
                  .of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.white70, fontSize: 16.0),
        )
            : null);
  }
}

