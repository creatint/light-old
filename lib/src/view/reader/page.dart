import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:light/src/model/read_mode.dart';
import 'content.dart';
import 'package:light/src/service/book_service.dart';
import 'package:light/src/model/book.dart';

class Page extends StatefulWidget {
  Page(
      {Key key,
      @required this.showMenu,
      @required this.bookDecoderFuture,
      @required this.readModeList,
      @required this.currentReadModeId,
      @required this.textStyle,
      @required this.textAlign,
      @required this.textDirection});

  ///用于显示菜单的回调函数
  final VoidCallback showMenu;

  ///资源服务实例
  Future<BookDecoder> bookDecoderFuture;

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
  PageController controller = new PageController(initialPage: 10);

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
  int sectionSize = 800;

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
  Map<int, Map<int, int>> records = <int, Map<int, int>>{};
  Record record;

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

  ///处理点击事件
  void handleTapDown(TapDownDetails details) {
    tapDownDetails = details;
  }

  ///处理点击弹起事件
  void handleTapUp(TapUpDetails tapUpDetails) {
    double x = tapUpDetails.globalPosition.dx;
    double y = tapUpDetails.globalPosition.dy;
    print('tap on x:$x y:$y');
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
      print(tapGrid);
    }
    if (x <= tapGrid['x1']) {
      //上一页
//      handlePrevPage();
      handlePageChanged(false);
    } else if (x >= tapGrid['x2']) {
      //下一页
//      handleNextPage();
      handlePageChanged(true);
    } else {
      if (y <= tapGrid['y1']) {
        //上一页
//        handlePrevPage();
        handlePageChanged(false);
      } else if (y >= tapGrid['y2']) {
        //下一页
//        handleNextPage();
        handlePageChanged(true);
      } else {
        //打开菜单
//        print('打开菜单');
        widget.showMenu();
      }
    }
  }

  ///试图更新页面时，更新页面数量
  void handleHorizontalDragDown(DragDownDetails) {
    int count;
    if (null != cache && cache.length >= sectionSize) {
      count = pageNumber + 2;
    } else if (null == section || section.isLast) {
      print('null == section = ${null == section}');
      print('section.isLast = ${section?.isLast}');
      count = pageNumber + 1;
    } else if (!section.isLast) {
      print('!section.isLast = ${!section?.isLast}');
      count = pageNumber + 2;
    }
    setState(() {
      childCount = count;
    });
  }

  ///[value]==true，下一页，[value]==false，上一页
  void handlePageChanged(bool next) {
    if (next) {
      print('下一页');
      if (section.isLast) {
        print('最后一页了');
        return;
      }
      controller.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      print('上一页');
      controller.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  ///根据偏移值获取字块
  ///无内容则返回null
  Section getSection(int offset, [int length]) {
    if (null != cache && cache.length >= sectionSize)
      return new Section(text: popCache);
    section =
        bookDecoder.getSection(offset: offset, length: length ?? sectionSize);
    print('section.isLast=${section.isLast}');
    if (null != section && section.isNotEmpty) {
      if (reverse)
        return section..text += (popCache ?? '');
      else
        return section..text = (popCache ?? '') + section.text;
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
    print('maxLines = $_maxLines');
    return _maxLines;
  }

  void handleScroll() {
//    debugPrint(controller.position.toString());
//    debugPrint(controller.page.toString());
//    int index = controller.page.toInt();
//    if (index >= pageNumber) {
//      controller.animateToPage(pageNumber,
//          duration: const Duration(microseconds: 1), curve: Curves.linear);
//    }
  }

  ///获取标题
  String getTitle() {
    print('获取标题:${section?.title ?? bookDecoder?.book?.title ?? ''}');
//    return title ?? section?.title ?? book?.book?.title ?? '';
//    return '我是标题';
    return section?.title ?? bookDecoder?.book?.title ?? '';
  }

  Content buildContent(int index) {
    print('buildContent@Page index=$index');
    pageNumber = index;
    Content _content = new Content(
        pageNumber: index,
        reverse: reverse,
        currentReadModeId: widget.currentReadModeId,
        readModeList: widget.readModeList,
        textStyle: widget.textStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        page: page,
        maxLines: maxLines);

    ///存在当前页面数据，直接获取内容
    if (records.containsKey(index)) {
      print('1:records[$index]存在：${records[index]}');
      _content.layout(getSection(records[index][0], records[index][1]).text);
      print(_content.content?.length);
      print('clipped length=${_content.clipped?.length}');
      cache = _content.clipped;
      return _content;
    }

    ///存在上一页面数据,获取下一页内容
    if (records.containsKey(index - 1)) {
      print('2:records[${index - 1}]存在：${records[index - 1]}');
      int i = 1;
      int offset = records[index - 1][0] + records[index - 1][1];
      print('offset=$offset');
      for (; i < 100; i++) {
        if (_content.load(getSection(offset, sectionSize * i))) {
          records[index] = {0: offset, 1: _content.length};
          break;
        }
      }
      print('clipped length=${_content.clipped?.length}');
      cache = _content.clipped;
      return _content;
    }
    print('无分页数据，初始化');
    int i = 1;
    for (; i < 100; i++) {
      if (_content.load(getSection(sectionOffset, sectionSize * i))) {
        records[index] = {0: sectionOffset, 1: _content.length};
        print('循环:$i次 使用${_content.length}个字符填满界面');
        print(records);
        print(_content.content?.length);
        print(_content.content);
        print('clipped length=${_content.clipped?.length}');
        cache = _content.clipped;
        return _content;
      }
    }
    _content.child = new Text('Null');
    return _content;
  }

  Widget pageBuilder(BuildContext context, int index) {
    print('pageBuilder@Page index=$index');
//    if (pageNumber <= 6) {
//      return null;
//    }
    if (null != section && section.isLast == true && pageNumber < index) {
      debugPrint('最后一页了@pageBuilder');
      return null;
    }
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
              print('page is $page');
              return new FutureBuilder(
                future: widget.bookDecoderFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<BookDecoder> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return new Center(child: new Text('加载中...'));
                  } else if (snapshot.connectionState == ConnectionState.done &&
                      !snapshot.hasError &&
                      snapshot.hasData) {
                    bookDecoder = snapshot.data;
                    return buildContent(index);
                  } else {
                    return new Center(child: new Text('故障！${snapshot.error}'));
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
    controller.addListener(handleScroll);
  }

  @override
  Widget build(BuildContext context) {
    print('build@Page');
    return new Scaffold(
      body: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          media = new Size(constraints.maxWidth, constraints.maxHeight);
          print('media is $media');
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
