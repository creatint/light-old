import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:light/src/model/read_mode.dart';
import 'content.dart';
import 'package:light/src/service/book_service.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/utils/page_calculator.dart';
import 'package:light/src/utils/custom_text_painter.dart';

class Page extends StatefulWidget {
  Page(
      {Key key,
      @required this.prefs,
      @required this.showMenu,
      @required this.bookDecoderFuture,
      @required this.bookService,
      @required this.readModeList,
      @required this.currentReadModeId,
      @required this.textStyle,
      @required this.textAlign,
      @required this.textDirection});

  final SharedPreferences prefs;

  ///用于显示菜单的回调函数
  final VoidCallback showMenu;

  ///资源服务实例
  final Future<BookDecoder> bookDecoderFuture;

  final BookService bookService;

  ///阅读主题
  final List<ReadMode> readModeList;
  final int currentReadModeId;

  ///内容显示格式
  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;

  @override
  PageState createState() => new PageState();
}

class PageState extends State<Page> {
  ///资源服务实例
  BookDecoder bookDecoder;

  /// 翻页控制器
  PageController controller;

  /// 分页计算器
  PageCalculator pageCalculator;

  /// 分页绘制器
  CustomTextPainter painter;

  ///滚动物理
  NeverScrollableScrollPhysics physics = new NeverScrollableScrollPhysics();

  ///分片代理
  SliverChildBuilderDelegate delegate;

  ///媒体显示尺寸
  Size media;

  ///文字显示尺寸
  Size _page;

  ///当前页码
  int pageNumber;

  ///旧页码
  int oldPageNumber = 0;

  ///最大显示行数，需要计算
  int _maxLines = 13;

  ///字块长度
  int sectionSize = 450;

  ///字块偏移值
  int sectionOffset = 0;

  ///是否倒序翻页
  bool reverse = false;

  ///记录点击坐标详情
  TapDownDetails tapDownDetails;

  ///内容
  Section section;

  int childCount = 1;

  ///用于计算点击手势区域的比例
  Map<String, List<int>> tapRatio = <String, List<int>>{
    'x': [1, 1, 1],
    'y': [1, 1, 1]
  };

  ///点击手势区域坐标点
  Map<String, double> tapGrid = <String, double>{};

  ///阅读记录
//  Map<int, List<int>> records = <int, List<int>>{};

  ///阅读记录
  Record records;

  ///缓存内容
  String cache;

  /// 计算总次数
  int times = 0;

  ///弹出缓存
  String get popCache {
    String _tmp = cache;
    cache = null;
    return _tmp;
  }

  ///逆序缓存内容
  String rcache;

  ///弹出逆序缓存
  String get poprCache {
    String _tmp = rcache;
    rcache = null;
    return _tmp;
  }

  void set page(Size size) {
    if (size != _page) {
      _page = size;
      pageCalculator.pageSize = _page;
      pageCalculator.maxLines = maxLines;
    }
  }

  Size get page => _page;

  ///处理屏幕改变事件
  void handleMediaChange(Size size) {
    if (media != size) {
      media = size;
      print('media changed,is $media');
    }
  }

  ///处理点击事件
  void handleTapDown(TapDownDetails details) {
    tapDownDetails = details;
  }

  ///处理点击弹起事件
  void handleTapUp(TapUpDetails tapUpDetails) {
    double x = tapUpDetails.globalPosition.dx;
    double y = tapUpDetails.globalPosition.dy;
    if (tapGrid.isEmpty) {
      double x1 = media.width *
          (tapRatio['x'][0] /
              (tapRatio['x'][0] + tapRatio['x'][1] + tapRatio['x'][2]));
      double x2 = media.width *
          ((tapRatio['x'][0] + tapRatio['x'][1]) /
              (tapRatio['x'][0] + tapRatio['x'][1] + tapRatio['x'][2]));
      double y1 = media.height *
          (tapRatio['y'][0] /
              (tapRatio['y'][0] + tapRatio['y'][1] + tapRatio['y'][2]));
      double y2 = media.height *
          ((tapRatio['y'][0] + tapRatio['y'][1]) /
              (tapRatio['y'][0] + tapRatio['y'][1] + tapRatio['y'][2]));
      tapGrid['x1'] = x1;
      tapGrid['x2'] = x2;
      tapGrid['y1'] = y1;
      tapGrid['y2'] = y2;
    }
    if (x <= tapGrid['x1']) {
      //上一页
      handlePageChanged(false);
    } else if (x >= tapGrid['x2']) {
      //下一页
      handlePageChanged(true);
    } else {
      if (y <= tapGrid['y1']) {
        //上一页
        handlePageChanged(false);
      } else if (y >= tapGrid['y2']) {
        //下一页
        handlePageChanged(true);
      } else {
        //打开菜单
        widget.showMenu();
      }
    }
  }

  ///试图更新页面时，更新页面数量
  void handleHorizontalDragDown(DragDownDetails) {
    int count;
//    print('handleHorizontalDragDown cache.length=${cache?.length}');
    if (null != cache && cache.length > 0) {
      count = pageNumber + 2;
    } else if (null == section || section.isLast) {
//      print('null == section = ${null == section}');
//      print('section.isLast = ${section?.isLast}');
      count = pageNumber + 1;
    } else if (!section.isLast) {
//      print('!section.isLast = ${!section?.isLast}');
      count = pageNumber + 2;
    }
    if (count != childCount)
      setState(() {
        childCount = count;
      });
  }

  ///[value]==true，下一页，[value]==false，上一页
  void handlePageChanged(bool next) {
    if (next) {
//      print('下一页');
      if (true == section?.isLast) {
        print('最后一页了');
        return;
      }
      controller.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
//      print('上一页');
      controller.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  ///根据偏移值获取字块
  ///无内容则返回null
  Section getSection(int offset, [int length]) {
//    if (null != cache && cache.length >= sectionSize)
//      return new Section(text: popCache);
    section =
        bookDecoder.getSection(offset: offset, length: length ?? sectionSize);
//    print('section.isLast=${section.isLast}');
    if (null != section && section.isNotEmpty) {
      return section;
//      if (reverse)
//        return section..text += (popCache ?? '');
//      else
//        return section..text = (popCache ?? '') + section.text;
    }
    return null;
  }

  ///标题样式的获取
  TextStyle get titleStyle => Theme
      .of(context)
      .textTheme
      .title
      .copyWith(fontSize: 14.0, color: Theme.of(context).disabledColor);

  int get maxLines {
    double lineHeight = widget.textStyle.fontSize * widget.textStyle.height;
    _maxLines = page.height ~/ lineHeight;
//    print('maxLines = $_maxLines');
    return _maxLines;
  }

  ///获取标题
  String getTitle() {
//    print('获取标题:${section?.title ?? bookDecoder?.book?.title ?? ''}');
    return section?.title ?? bookDecoder?.book?.title ?? '';
  }


  // 构建内容页面
  Widget buildContent2(int index) {
    print('buildContent2@Page index=$index');
    if (index != pageNumber) {
      pageNumber = index;
      cache = null;

      ///存在当前分页数据，直接获取内容
      if (records.containsKey(index)) {
        print('分页(1)：${records[index]}');
        pageCalculator.layout(getSection(records[index][0], records[index][1]).text);
      } else if (records.containsKey(index - 1)) {
        ///存在上一页面数据,获取下一页内容
        // 计算下一页偏移值
        int offset = records[index - 1][0] + records[index - 1][1];
        // 最大循环100次，正常情况下10次左右
        for (int i = 1; i < 100; i++) {
          Section section = getSection(offset, sectionSize * i);
          if (pageCalculator.load(section.text)) {
            records[index] = [offset, pageCalculator.length];
            print('分页(2)：${records[index]}');
            break;
          }
        }
        times += pageCalculator.times;
        print('计算 ${pageCalculator.times} 次\n'
            '平均每页计算 ${times / (index + 1) * 10~/1/10}\n'
            '共计算 ${times} 次');
        pageCalculator.times = 0;
      } else {
        for (int i = 1; i < 100; i++) {
          Section section = getSection(sectionOffset, sectionSize * i);
          if (pageCalculator.load(section.text)) {
            records[index] = [sectionOffset, pageCalculator.length];
            print('分页(3)：${records[index]}');
            break;
          }
        }
        times += pageCalculator.times;
        print('计算 ${pageCalculator.times} 次\n'
            '平均每页计算 ${times / (index + 1) * 10~/1/10}\n'
            '共计算 ${times} 次');
        pageCalculator.times = 0;
        return new Text('错误码：001E1');
      }
    }
    return new CustomPaint(
      painter: painter,
    );
  }

  Widget pageBuilder(BuildContext context, int index) {
    print('pageBuilder@Page index=$index pageNumber=$pageNumber');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: new BoxDecoration(
          color: widget.readModeList[widget.currentReadModeId].backgroundColor,
          image: widget.readModeList[widget.currentReadModeId].image),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: 30.0,
            child: new Row(
              children: <Widget>[
                new Container(
                    child: new Text(
                  getTitle(),
                  style: titleStyle,
                )),
              ],
            ),
          ),
          new Expanded(
            child: new LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              page = new Size(constraints.maxWidth, constraints.maxHeight);
              pageCalculator.maxLines = maxLines;
//              print('page:$page');
              return new FutureBuilder(
                future: widget.bookDecoderFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<BookDecoder> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return new Center(child: new Text('读取中...'));
                  } else if (snapshot.connectionState == ConnectionState.done &&
                      !snapshot.hasError &&
                      snapshot.hasData) {
                    bookDecoder = snapshot.data;
                    records.reset(
                        pageSize: page,
                        bookDecoder: bookDecoder,
                        textStyle: widget.textStyle,
                        textAlign: widget.textAlign,
                        textDirection: widget.textDirection,
                        maxLines: maxLines);
                    return buildContent2(index);
                  } else {
                    return new Center(
                        child: new Text('Oops！${snapshot.error}'
                            '\n错误代码：001E2'));
                  }
                },
              );
            }),
          ),
          new Container(
            height: 30.0,
//            child: new Row(
//              children: <Widget>[
//                new RotatedBox(
//                  child: new Icon(Icons.battery_std),
//                  quarterTurns: 1,
//                )
//              ],
//            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    records = new Record(prefs: widget.prefs);
    controller = new PageController();
    pageCalculator = new PageCalculator(
        key: 'page',
        textStyle: widget.textStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection);
    painter =
        new CustomTextPainter(textPainter: pageCalculator.textPainter);
  }

  @override
  void dispose() {
    records.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build@Page');
    return new Scaffold(
      body: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          handleMediaChange(
              new Size(constraints.maxWidth, constraints.maxHeight));
          return GestureDetector(
            onTapUp: handleTapUp,
            onTapDown: handleTapDown,
            onHorizontalDragDown: handleHorizontalDragDown,
            child: new PageView.custom(
              key: new Key(widget.currentReadModeId.toString()),
              controller: controller,
              scrollDirection: Axis.horizontal,
              childrenDelegate: new SliverChildBuilderDelegate(pageBuilder,
                  childCount: childCount),
            ),
          );
        },
      ),
    );
  }
}
