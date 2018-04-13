import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:light/src/model/read_mode.dart';
import 'package:light/src/service/book_service.dart';

class Page extends StatefulWidget {
  Page(
      {Key key,
      @required this.prefs,
      @required this.bookDecoder,
      @required this.initialPageNumber,
      @required this.currentReadModeId,
      @required this.readModeList,
      @required this.handleShowMenu,
      @required this.sectionSize
//    @required this.title,
//    @required this.text,
      })
      : super(key: key);
  final Future<BookDecoder> bookDecoder;
  final initialPageNumber;
  final SharedPreferences prefs;
  final int currentReadModeId;
  final List<ReadMode> readModeList;
  final VoidCallback handleShowMenu;
  final sectionSize;

//  final String title;
//  final Future<String> text;

  @override
  _PageState createState() => new _PageState(sectionSize: sectionSize);
}

class _PageState extends State<Page> {
  _PageState({@required this.sectionSize});

  ScrollController scrollController;
  ScrollPhysics scrollPhysics;
  BookDecoder book;
  String title;
  final Color backgroundColor = new Color.fromRGBO(241, 236, 225, 1.0);
  final Color fontColor = new Color.fromRGBO(38, 38, 38, 1.0);
  final double fontSize = 18.0;
  final double fontHeight = 1.8;

//  final double fontHeight = 1.0;
  final List<String> list = <String>[]; //动态的内容列表
  final sectionSize; //每次读取字数
  int initSectionOffset = 0; //当前字块偏移值
  bool sectionReverse = false;
  Section section;

  int currentSectionOffset; //当前字块偏移值
  final List<Widget> pages = <Widget>[];
  Widget page;
  ReadMode readMode;
  int currentPageNumber = 1; //当前页码
  double mediaHeight; //屏幕高度
  double mediaWidth; //屏幕宽度
  double pageHeight; //内容高度
  double pageWidth; //内容宽度
  TapDownDetails tapDownDetails;
  Map<String, List<int>> ratio = <String, List<int>>{
    'x': [4, 3, 4],
    'y': [4, 3, 4]
  };
  Map<String, double> grid = <String, double>{};

  ///初始化主题
  ///根据[widget.currentReadModeId]与[widget.readModeList]获取当前
  ///的显示主题，数据来自于[Reader]，默认显示第一个主题
  void initReadMode() {
    readMode = widget.readModeList?.firstWhere((ReadMode mode) {
      return mode.id == widget.currentReadModeId;
    }, orElse: () {
      print('无法加载主题');
    });
  }

  ///获取标题
  String getTitle() {
    print('获取标题:${section?.title ?? book?.book?.title ?? ''}');
    return title ?? section?.title ?? book?.book?.title ?? '';
  }

  ///根据字块偏移值，获取[sectionSize]长度的字块
  Section getSection(int index) {
    print('get section offset = $currentSectionOffset');
    section =
        book.getSection(offset: currentSectionOffset, length: sectionSize);
    return section;
  }

  ///TODO:获取目录
  List<String> getCatalog() {
    return null;
  }

  ///用于监听滚动事件
  void handleScroll() {
//    print('S  offset: ${scrollController.offset}');
//    print('maxExtent: ${position.maxScrollExtent}');
//    if ((position.maxScrollExtent - position.pixels) <= pageHeight * 2) {
//      print('handleScroll: 获取内容');
//      setState(() {
//        list.add(getSection(sectionOffset));
//      });
//    }
  }

  ///计算每页跳跃高度[scrollHeight]
  ///现根据字号[fontSize]与字高[fontHeight]来计算行高[lineHeight]
  ///当前页面高度[pageHeight]加上行高的下行偏差(fontHeight - 1) / 2 * fontSize)
  ///再除以行高，得到最大行数[lines]
  ///用最大行数[lines]乘以行高[lineHeight]，再减去一个下行偏差，
  ///得到裁剪后的页面高度[scrollHeight]
  ///以此来避免底部可能显示不全的问题
  double get scrollHeight {
    double lineHeight = fontSize * fontHeight + 3.0 * fontHeight;
    print('line height=$lineHeight');
    int lines = pageHeight ~/ lineHeight;
    print('lines : $lines');
    double height = lines * lineHeight;
    print('scroll height: $height');
    return height;
  }

  ///单次滚动距离
  double get scrollOffset => scrollHeight * (currentPageNumber.abs() - 1);

  ///[value]==true，下一页，[value]==false，上一页
  void handlePageChanged(bool value) {
    if (value) {
      print('下一页');
    } else {
      print('上一页');
    }
    print('old currentPageNumber: $currentPageNumber');
    ScrollPosition position = scrollController.position;
//    print('current offset: ${scrollController.offset}');
//    print('max offset: ${position.maxScrollExtent}');
    if (value &&
        !sectionReverse &&
        scrollController.offset >= position.maxScrollExtent) {
      print('滚动的极限');
      return;
    } else if (!value &&
        sectionReverse &&
        scrollController.offset >= position.maxScrollExtent) {
      print('滚动的极限2');
      return;
    }

    ///根据条件，对页码进行增一或减一
    if (!value) {
      if (sectionReverse) {
        currentPageNumber++;
      } else {
        currentPageNumber--;
      }
    } else {
      if (sectionReverse) {
        currentPageNumber--;
      } else {
        currentPageNumber++;
      }
    }

    ///当前页码小于等于0，并且initSectionOffset>0，则可创建逆序列表
    if (currentPageNumber <= 0 && initSectionOffset > 0) {
      reversePage();
      return;
    } else if (currentPageNumber <= 0) {
      currentPageNumber = 1;
    }

//    print('new currentPageNumber: $currentPageNumber');
//    print('want up to: ${math.min(scrollOffset, position.maxScrollExtent)}');

    position.animateTo(math.min(scrollOffset, position.maxScrollExtent),
        duration: const Duration(microseconds: 1), curve: Curves.linear);
    setState(() {
      title = section?.title ?? book?.book?.title ?? '';
    });
  }

  void handleTapDown(TapDownDetails details) {
    tapDownDetails = details;
  }

  ///处理点击弹起事件
  ///调用[calculateTapAction]方法以执行相应的功能
  void handleTapUp(TapUpDetails tapUpDetails) {
    calculateTapAction(
        tapDownDetails: tapDownDetails,
        tapUpDetails: tapUpDetails,
        size: new Size(mediaWidth, mediaHeight));
  }

  ///计算点击操作,
  ///屏幕被分割为类似九宫格的形状，
  ///功能区对应的操作分别是：
  ///上一页[handlePrevPage]、下一页[handleNextPage]、菜单[widget.handleShowMenu]
  ///在旋转屏幕后需要重新计算[grid]
  void calculateTapAction(
      {TapDownDetails tapDownDetails, TapUpDetails tapUpDetails, Size size}) {
    double x = tapDownDetails.globalPosition.dx;
    double y = tapDownDetails.globalPosition.dy;
    if (grid.isEmpty) {
      double x1 = size.width *
          (ratio['x'][0] / (ratio['x'][0] + ratio['x'][1] + ratio['x'][2]));
      double x2 = size.width *
          ((ratio['x'][0] + ratio['x'][1]) /
              (ratio['x'][0] + ratio['x'][1] + ratio['x'][2]));
      double y1 = size.height *
          (ratio['y'][0] / (ratio['y'][0] + ratio['y'][1] + ratio['y'][2]));
      double y2 = size.height *
          ((ratio['y'][0] + ratio['y'][1]) /
              (ratio['y'][0] + ratio['y'][1] + ratio['y'][2]));
      grid['x1'] = x1;
      grid['x2'] = x2;
      grid['y1'] = y1;
      grid['y2'] = y2;
    }
    if (x <= grid['x1']) {
      //上一页
//      handlePrevPage();
      handlePageChanged(false);
    } else if (x >= grid['x2']) {
      //下一页
//      handleNextPage();
      handlePageChanged(true);
    } else {
      if (y <= grid['y1']) {
        //上一页
//        handlePrevPage();
        handlePageChanged(false);
      } else if (y >= grid['y2']) {
        //下一页
//        handleNextPage();
        handlePageChanged(true);
      } else {
        //打开菜单
//        print('打开菜单');
        widget.handleShowMenu();
      }
    }
  }

  ///构建显示字块，它作为无限列表的元素显示
  ///调用[getSection]方法，获取第[index]的字块
  ///[getSection]是与[BookService]的桥梁
  Widget buildSections(BuildContext context, int index) {
//    print('buildSections index=$index');
    if (!sectionReverse) {
//      print('正序');
      currentSectionOffset = index + initSectionOffset;
    } else {
//      print('倒序');
      currentSectionOffset = initSectionOffset - index - 1;
    }
    if (currentSectionOffset < 0) {
      currentSectionOffset = 0;
      return null;
    }
    if (currentSectionOffset > book.maxSectionOffset) {
      currentSectionOffset = book.maxSectionOffset;
    }
    return new Content(
//      section: getSection(index),
      section: getSection(index),
      style: bodyStyle,
      minHeight: scrollHeight,
    );
  }

  ///构建逆序页面
  void reversePage() {
    print('reversePage');
    scrollController = new ScrollController();
    scrollController.addListener(handleScroll);
    setState(() {
      sectionReverse = !sectionReverse;
      currentPageNumber = 1;
    });
  }

  ///获取内容显示组件
  Widget getPage() {
    print('getpage');
    page = new ListView.builder(
        key: new Key(sectionReverse.toString()),
        padding: const EdgeInsets.all(0.0),
        reverse: sectionReverse,
        physics: scrollPhysics,
        controller: scrollController,
        itemCount: sectionReverse
            ? initSectionOffset
            : book.maxSectionOffset - initSectionOffset,
        itemBuilder: buildSections);
    if (null == page) {
      print('page == null');
    }
    return page;
  }

  ///构建内容页面
  ///用于展示[Section]列表，此无限列表禁止手动划动
  ///通过[ScrollController]实现间断跳跃
  Widget buildPages() {
    print('buildPages');
    pages.clear();
    if (pages.isEmpty) {
      pages.add(getPage());
//    pages.add(new Text('hello'));
    }
    if (pages.isEmpty) {
      print('pages.isEmpty = true');
    }
    return new Stack(
      children: pages,
    );
  }

  ///标题样式的获取
  TextStyle get titleStyle => Theme
      .of(context)
      .textTheme
      .title
      .copyWith(fontSize: 14.0, color: Theme.of(context).disabledColor);

  ///正文样式的获取
  TextStyle get bodyStyle => new TextStyle(
      color: readMode?.fontColor ?? fontColor,
      fontSize: fontSize,
      height: fontHeight);

  ///获取初始化页码[currentPageNumber]，
  ///执行初始化阅读读题方法[initReadMode]，
  ///添加[scrollController]的监听者[handleScroll]
  @override
  void initState() {
    super.initState();
    print('initState PageState');
//    initSectionOffset = 19740;
//    initSectionOffset = 100;
//    print('currentPageNumber = $currentPageNumber');
//    print('initSectionOffset = $initSectionOffset');
    initReadMode();
    scrollController = new ScrollController();
    scrollController.addListener(handleScroll);
//    scrollPhysics =
//    new NeverScrollableScrollPhysics(parent: new OverflowScrollPhysics());
    scrollPhysics =
        new NeverScrollableScrollPhysics(parent: new ClampingScrollPhysics());
  }

  @override
  Widget build(BuildContext context) {
    print('build _PageState');
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      mediaHeight = constraints.maxHeight;
      mediaWidth = constraints.maxWidth;
      return new GestureDetector(
        onTapDown: handleTapDown,
        onTapUp: handleTapUp,
        child: new Container(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
          decoration: new BoxDecoration(
              color: readMode?.backgroundColor ?? backgroundColor,
              image: readMode?.image),
          child: new Column(
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
                child: new LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  pageHeight = constraints.maxHeight;
                  pageWidth = constraints.maxWidth;
                  print('pageHeight: $pageHeight\npageWidth: $pageWidth');
                  return new FutureBuilder(
                      future: widget.bookDecoder,
                      builder: (BuildContext context,
                          AsyncSnapshot<BookDecoder> snapshot) {
                        print('状态：${snapshot.connectionState}');
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return new Center(child: new Text('读取中'));
                        } else if (snapshot.connectionState ==
                                ConnectionState.done &&
                            !snapshot.hasError &&
                            snapshot.data != null) {
                          book = snapshot.data;
                          return Center(
                            child: new Container(
                                height: scrollHeight, child: buildPages()),
                          );
                        } else {
                          return new Center(child: new Text('读取失败'));
                        }
                      });
                }),
              ),
              new Container(
                height: 30.0,
                child: new Row(
                  children: <Widget>[
                    new RotatedBox(
                      child: new Icon(Icons.battery_std),
                      quarterTurns: 1,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

///内容显示块
class Content extends StatelessWidget {
  Content({@required this.section, @required this.style, this.minHeight});

//  final String section;
  final Section section;
  final TextStyle style;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    print('build Section');
    return new Text(
        section.text,
        textAlign: TextAlign.start,
        style: style,
      );
    return new Container(
      constraints: new BoxConstraints(minHeight: 4.0),
      color: Colors
          .primaries[new math.Random().nextInt(1000) % Colors.primaries.length],
      child: new Text(
        section.text,
        style: style,
      ),
    );
  }
}
