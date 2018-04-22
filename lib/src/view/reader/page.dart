import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:light/src/model/read_mode.dart';
import 'content.dart';
import 'package:light/src/service/book_service.dart';
import 'package:light/src/model/book.dart';

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

  ///翻页控制器
  PageController controller;

  ///滚动物理
  NeverScrollableScrollPhysics physics = new NeverScrollableScrollPhysics();

  ///分片代理
  SliverChildBuilderDelegate delegate;

  ///媒体显示尺寸
  Size media;

  ///文字显示尺寸
  Size page;

  ///当前页码
  int pageNumber = 0;

  ///旧页码
  int oldPageNumber = 0;

  ///最大显示行数，需要计算
  int _maxLines = 13;

  ///字块长度
  int sectionSize = 400;

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
    print('获取标题:${section?.title ?? bookDecoder?.book?.title ?? ''}');
//    return title ?? section?.title ?? book?.book?.title ?? '';
//    return '我是标题';
    return section?.title ?? bookDecoder?.book?.title ?? '';
  }

  // 构建内容页面
  Content buildContent(int index) {
    print('buildContent@Page index=$index');
    pageNumber = index;
    cache = null;
    Content _content = new Content(
        pageNumber: pageNumber,
        reverse: reverse,
        textStyle: widget.textStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        page: page,
        maxLines: maxLines);

    ///存在当前分页数据，直接获取内容
    if (records.containsKey(index)) {
      print('分页(1)：${records[index]}');
      _content.layout(getSection(records[index][0], records[index][1]).text);
      return _content;
    }

    ///存在上一页面数据,获取下一页内容
    if (records.containsKey(index - 1)) {
      // 计算下一页偏移值
      int offset = records[index - 1][0] + records[index - 1][1];
      // 最大循环100次，正常情况下10次左右
      for (int i = 1; i < 100; i++) {
        if (_content.load(getSection(offset, sectionSize * i))) {
          records[index] = [offset, _content.length];
          print('分页(2)：${records[index]}');
          break;
        }
      }
      cache = _content.clipped;
      return _content;
    }
    for (int i = 1; i < 100; i++) {
      if (_content.load(getSection(sectionOffset, sectionSize * i))) {
        records[index] = [sectionOffset, _content.length];
        print('分页(3)：${records[index]}');
        cache = _content.clipped;
        return _content;
      }
    }
    _content.child = new Text('错误码：001E1');
    return _content;
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
                        media: page,
                        bookDecoder: bookDecoder,
                        textStyle: widget.textStyle,
                        textAlign: widget.textAlign,
                        textDirection: widget.textDirection,
                        maxLines: maxLines);
                    return buildContent(index);
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
  }

  @override
  void dispose() {
    super.dispose();
    records.close();
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
