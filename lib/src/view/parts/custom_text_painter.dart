import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CustomTextPainter extends CustomPainter {
  CustomTextPainter({@required this.textPainter});

  final TextPainter textPainter;

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(CustomTextPainter oldDelegate) => true;
}
