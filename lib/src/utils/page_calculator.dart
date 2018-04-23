import 'package:flutter/widgets.dart';

class PageCalculator {
  factory PageCalculator({
    String key = 'default',
    Size size,
    TextStyle textStyle,
    TextAlign textAlign,
    TextDirection textDirection,
    int maxLines,
  }) {
    if (_cache.containsKey(key)) {
      return _cache[key]
        ..pageSize = size
        ..textStyle = textStyle
        ..textAlign = textAlign
        ..textDirection = textDirection;
    } else {
      _cache[key] = new PageCalculator._internal(
          size: size,
          textStyle: textStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          maxLines: maxLines);
      return _cache[key];
    }
  }

  PageCalculator._internal({
    Size size,
    TextStyle textStyle,
    TextAlign textAlign,
    TextDirection textDirection,
    int maxLines,
  })  : this.pageSize = size,
        this._textStyle = textStyle,
        this._textAlign = textAlign,
        this._textDirection = textDirection,
        this._maxLines = maxLines,
        this.textPainter = new TextPainter(
          textAlign: textAlign,
          textDirection: textDirection,
          maxLines: maxLines,
        );

  static Map<String, PageCalculator> _cache = <String, PageCalculator>{};

  /// 计算次数
  int times = 0;

  /// 页面尺寸
  Size pageSize;

  /// 文本样式
  TextStyle _textStyle;

  /// 文本排版
  TextAlign _textAlign;

  /// 文本阅读方向，默认由左至右
  TextDirection _textDirection;

  /// 最大行
  int _maxLines;

  /// 文本绘制器
  TextPainter textPainter;

  /// 待绘制文本
  String content;

  /// 待绘制文本长度
  int length;

  /// 剪切掉的文本
  String clipped;

  /// 设置文本样式
  set textStyle(TextStyle textStyle) {
    if (null == textStyle) return;
    _textStyle = textStyle;
  }

  /// 设置文本排版
  set textAlign(TextAlign textAlign) {
    if (null == textAlign) return;
    _textAlign = textAlign;
    textPainter.textAlign = _textAlign;
  }

  /// 设置文本阅读方向
  set textDirection(TextDirection textDirection) {
    if (null == textDirection) return;
    _textDirection = textDirection;
    textPainter.textDirection = _textDirection;
  }

  /// 设置最大行数
  set maxLines(int maxLines) {
    if (null == maxLines) return;
    _maxLines = maxLines;
    textPainter.maxLines = _maxLines;
  }

  /// 获取带样式的文本对象
  TextSpan getTextSpan(String text) {
    return new TextSpan(text: text, style: _textStyle);
  }

  /// 接收内容
  /// 追加内容返回false
  /// 计算完毕返回true
  bool load(String text) {
    if (layout(text)) {
      return false;
    }

    int start = 0;
    int end = text.length;
    int mid = (end + start) ~/ 2;

    // 最多循环20次
    for (int i = 0; i < 20; i++) {
//      print(
//          '================= start:$start mid: $mid end: $end ==================');
      if (layout(text.substring(0, mid))) {
        if (mid <= start || mid >= end) break;
        ;
        // 未越界
        start = mid;
        mid = (start + end) ~/ 2;
      } else {
        // 越界
        end = mid;
        mid = (start + end) ~/ 2;
      }
    }
    length = mid;
    return true;
  }

  /// 计算待绘制文本
  /// 未超出边界返回true
  /// 超出边界返回false
  bool layout(String text) {
    times++;
    text = text ?? '';
    textPainter
      ..text = getTextSpan(text)
      ..layout(maxWidth: pageSize.width);
    return !didExceed;
  }

  /// 是否超出边界
  bool get didExceed {
    return textPainter.didExceedMaxLines ||
        textPainter.size.height > pageSize.height;
  }
}
