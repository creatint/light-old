import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {Key key,
      this.title,
      this.shape,
      this.onPressed,
      this.borderColor,
      this.splashColor,
      this.color,
      this.child,
      this.width,
      this.iconData,
      this.active: false});

  final String title;
  final ShapeBorder shape;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color splashColor;
  final Color color;
  final Widget child;
  final double width;
  final IconData iconData;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return new Container(
        constraints: new BoxConstraints(maxWidth: width ?? 40.0),
//        margin: const EdgeInsets.symmetric(horizontal: 8.0),
//        margin: const EdgeInsets.symmetric(horizontal: 0.0),
//        margin: const EdgeInsets.all(8.0),
        child: new OutlineButton(
          padding: const EdgeInsets.all(0.0),
          shape: shape ?? const StadiumBorder(),
          color: color ?? Colors.transparent,
          splashColor: splashColor ?? Colors.transparent,
          borderSide: new BorderSide(
              color: active ? Colors.orange : borderColor ?? Colors.white30,
              width: 2.0),
          onPressed: onPressed,
          child: iconData != null
              ? new Icon(
                  iconData,
                  color: Theme.of(context).accentIconTheme.color,
                )
              : (child ??
                  new Text(
                    title,
                    style: Theme.of(context).accentTextTheme.button,
                  )),
        ));
  }
}
