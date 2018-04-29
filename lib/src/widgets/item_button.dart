import 'package:flutter/material.dart';

class ItemButton extends StatelessWidget {
  ItemButton({
    Key key,
    this.onTap,
    this.icon,
    this.title,
    this.iconSize,
    this.width
  });

  final VoidCallback onTap;
  final Icon icon;
  final Widget title;
  final double iconSize;
  final double width;

  @override
  Widget build(BuildContext context) {
    return new IconTheme(
      data: Theme.of(context).iconTheme.copyWith(size: iconSize ?? 24.0),
      child: new InkResponse(
        onTap: onTap,
        child: new Container(
          width: width ?? (iconSize ?? 24.0) * 3,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Align(
                alignment: Alignment.topCenter,
                heightFactor: 1.0,
                child: icon,
              ),
              new Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1.0,
                child: title,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


