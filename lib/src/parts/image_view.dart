import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageView extends StatefulWidget {
  ImageView({this.image});

  final Image image;

  @override
  ImageViewState createState() => new ImageViewState();
}

class ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: widget.image,
    );
  }
}
