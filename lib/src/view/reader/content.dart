import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../parts/custom_text_painter.dart';
import 'package:light/src/model/read_mode.dart';
import 'package:light/src/service/book_service.dart';

class Content extends StatelessWidget {
  Content(
      {Key key,
      @required this.pageNumber,
      @required this.reverse,
      @required this.textStyle,
      @required this.textAlign,
      @required this.textDirection,
      @required this.maxLines,
      @required this.page,
      this.child});

  Widget child;

  final int pageNumber;

  ///页面尺寸
  final Size page;

  ///是否倒序翻页
  final reverse;

  ///内容显示格式
  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final int maxLines;

  ///渲染次数
  int renderTimes = 0;

  ///文字绘制器
  TextPainter _textPainter;

  ///页面绘制器
  CustomTextPainter _painter;

  ///当前渲染的内容
  String content;

  ///缓存内容
  String cache;

  ///裁剪掉的内容
  String _clipped;

  set clipped(String str) {
    _clipped = str;
  }

  String get clipped {
    String _tmp = _clipped;
    _clipped = null;
    return _tmp;
  }

  ///获取当前渲染的字符数量
  int get length => content?.length ?? 0;

  ///页面高度 + 行高下缘
  double get height =>
      page.height + (textStyle.fontSize * (textStyle.height - 1)) / 2;

  ///获取页面宽度
  double get width => page.width;

  ///获取文字渲染rending
  TextSpan getTextSpan(String text) {
    return new TextSpan(style: textStyle, text: text);
  }

  ///获取文字绘制器
  TextPainter getTextPainter(TextSpan textSpan) {
    return new TextPainter(
        text: textSpan,
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: maxLines,
        ellipsis: 'ellipsis');
  }

  ///获取页面绘制器
  CustomTextPainter get painter {
    if (null == _painter) {
      _painter = new CustomTextPainter(textPainter: _textPainter);
    }
    return _painter;
  }

  ///装载内容
  ///返回ture时则已完成
  ///返回false时则未完成
  bool load(Section section) {
    cache = section.text;

    // 指定child直接返回true
    if (null != child) return true;

    // 内容为空直接返回true
    if (null == cache) return true;

    // 判断当前内容是否填满页面
    layout(cache);
    if (_textPainter.size.height <= height && !section.isLast) {
      // 当前块未填满，追加字块
      return false;
    } else if (_textPainter.size.height <= height && section.isLast) {
      // 最后一块未填满，直接返回true
      return true;
    }

    ///通过中间值算法，计算出当前页面所能显示的字符串
    int start = 0;
    int end = cache.length;
    int mid = (end + start) ~/ 2;

    // 循环20次，可处理2^20长度的内容
    loop:
    for (int i = 0; i < 20; i++) {
//      print('分割 start:$start mid:$mid end:$end');
      // 顺序不同，截取不同
      if (reverse)
        layout(cache.substring(mid, end));
      else
        layout(cache.substring(0, mid));

      if (_textPainter.size.height > height) {
        // 超出最大行或超出页面高度
        if (reverse) {
          start = mid;
          mid = (end + start) ~/ 2;
        } else {
          end = mid;
          mid = (end + start) ~/ 2;
        }
        continue loop;
      } else {
//        print('排除恰好情况');
//        if (reverse) {
//          mid--;
//          layout(cache.substring(mid, end));
//        } else {
//          mid++;
//          layout(cache.substring(0, mid));
//        }
////        print('位置 start=$start mid=$mid end=$end');
//        if (_textPainter.didExceedMaxLines ||
//            _textPainter.size.height > height) {
//          ///内容符合要求
////          print('内容符合要求');
//          if (reverse) {
//            mid++;
//            layout(cache.substring(mid, end));
//          } else {
//            mid--;
//            layout(cache.substring(0, mid));
//          }
//          print('位置 start=$start mid=$mid end=$end');
//          break;
//        }

        if (start == mid || mid == end) {
          //已找到位置
//          print('找到位置 start=$start mid=$mid end=$end');
          break loop;
        }
        //可能不够
        if (reverse) {
          if (start > 0) {
            //缓存足够，不必再请求内容
//            print('内容不足，取前1/2');
            end = mid;
            mid = (start + end) ~/ 2;
            continue;
          } else {
            ///第一次执行就内容不足，需要内容
//            print('追加内容 cache.length=${cache.length}\isLast=${section.isLast}');
            if (section.isLast) return true;
            return false;
          }
        } else {
//          print('内容不足，取后1/2');
          start = mid;
          mid = (end + start) ~/ 2;
          continue loop;
        }
      }
    }

    ///避免单词截断
    String text = '';
    if (reverse) {
      Match match = new RegExp(r'^([^a-zA-Z0-1]+)[ ]+[^\r\n\t]*')
          .firstMatch(cache.substring(mid, end));
      if (null != match) {
        text = match.group(1);
//        print('text = $text');
        layout(cache.substring(mid - text.length, end));
      }
      clipped = cache.substring(0, mid - text.length);
    } else {
      Match match = new RegExp(r'[^\r\n\t]*[ ]+([a-zA-Z0-1]+)$')
          .firstMatch(cache.substring(0, mid));
      if (null != match) {
        text = match.group(1);
//        print('text = $text');
        layout(cache.substring(0, mid - text.length));
      }
      clipped = cache.substring(mid - text.length, cache.length);
    }
//    print('content=$content');
//    print('clipped:$_clipped');
    return true;
  }

  ///内存中渲染文字页面，返回页面大小
  Size layout(String str) {
//    print('layout@Content');
    renderTimes++;
    content = str ?? '';
    _textPainter = getTextPainter(getTextSpan(str))
      ..layout(minWidth: 20.0, maxWidth: width);
//    print('content length = ${content.length}');
//    print('${_textPainter.size.height} <= $height = '
//        '${_textPainter.size.height <= height}');
//    print('painter   size = ${_textPainter.size}');
//    print('page      size = Size($width, $height)');
//    print('_textPainter.size.height > height = ${_textPainter.size.height > height}');
    return _textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: painter,
//      child: new Center(child: new Text('No. $pageNumber')),
    );
  }
}
