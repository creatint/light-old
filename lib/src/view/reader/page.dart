import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:light/src/model/read_mode.dart';
import 'package:light/src/service/book_service.dart';

class Page extends StatefulWidget {
  Page(
      {Key key,
      @required this.prefs,
      @required this.book,
      @required this.initialPageNumber,
      @required this.currentReadModeId,
      @required this.readModeList,
      @required this.handleShowMenu
//    @required this.title,
//    @required this.text,
      })
      : super(key: key);
  final BookDecoder book;
  final initialPageNumber;
  final SharedPreferences prefs;
  final int currentReadModeId;
  final List<ReadMode> readModeList;
  final VoidCallback handleShowMenu;

//  final String title;
//  final Future<String> text;

  @override
  _PageState createState() => new _PageState();
}

class _PageState extends State<Page> {
  final ScrollController scrollController = new ScrollController();
  final NeverScrollableScrollPhysics scrollPhysics =
      new NeverScrollableScrollPhysics();
  final Color backgroundColor = new Color.fromRGBO(241, 236, 225, 1.0);
  final Color fontColor = new Color.fromRGBO(38, 38, 38, 1.0);
  final double fontSize = 18.0;
  final double fontHeight = 1.8;
  final List<String> list = <String>[]; //动态的内容列表
  final sectionSize = 200; //每次读取字数
  final List<Widget> pages = <Widget>[];
  ReadMode readMode;
  int currentPageNumber; //当前页码
  int currentSectionNumber; //当前字块页码
  double pageHeight;
  double pageWidth;
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

  void refreshSections() {}

  ///获取标题
  String getTitle() {
    return '这是标题';
  }

  ///根据字块偏移值，获取[sectionSize]长度的字块
  String getSection(int number) {
    String str = 'section: $number\n';
    for (int i = 0; i < sectionSize; i++) {
      str += ' content: $i ';
    }
    return str;
  }

  ///TODO:获取目录
  List<String> getCatalog() {
    return null;
  }

  ///用于监听滚动事件
  void handleScroll() {
    print('Scrolled.');
//    ScrollPosition position = scrollController.position;
//    print('offset: ${position.pixels}');
//    print('maxExtent: ${position.maxScrollExtent}');
//    if ((position.maxScrollExtent - position.pixels) <= pageHeight * 2) {
//      print('handleScroll: 获取内容');
//      setState(() {
//        list.add(getSection(currentSectionNumber));
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
    double lineHeight = fontSize * fontHeight;
    int lines = (pageHeight + (fontHeight - 1) / 2 * fontSize) ~/ lineHeight;
    return lines * lineHeight - (fontHeight - 1) / 2 * fontSize;
  }

  ///滚动到上一页
  ///根据页码[currentPageNumber]计算滚动偏移值，
  ///需要注意页码与偏移值的关系
  void handlePrevPage() {
    print('上一页');
    ScrollPosition position = scrollController.position;
//    print(position);
    double maxScrollExtent = position.maxScrollExtent;
    double offset = position.pixels;
    print('scrollHeight: $scrollHeight');
    print('currentPageNumber: $currentPageNumber');
    if (currentPageNumber <= 2) {
      currentPageNumber = 1;
    } else {
      currentPageNumber--;
    }
    double y = scrollHeight * (currentPageNumber - 1);
    print('want up to $y');
    print('offset: $offset');
    print('max: $maxScrollExtent');
    position.animateTo(y,
        duration: const Duration(microseconds: 1), curve: Curves.linear);
  }

  ///滚动到下一页
  ///根据页码[currentPageNumber]计算滚动偏移值，
  ///需要注意页码与偏移值的关系
  void handleNextPage() {
    print('下一页');
    ScrollPosition position = scrollController.position;
//    print(position);
    double maxScrollExtent = position.maxScrollExtent;
    double offset = position.pixels;
    print('scrollHeight: $scrollHeight');
    print('currentPageNumber: $currentPageNumber');
    currentPageNumber++;
    double y = scrollHeight * (currentPageNumber - 1);
    print('want down to: $y');
    print('offset: $offset');
    print('max: $maxScrollExtent');
    position.animateTo(y,
        duration: const Duration(microseconds: 1), curve: Curves.linear);
  }

  void handleTapDown(TapDownDetails details) {
//    media = MediaQuery.of(context);
//    print('handleTapDown');
//    print(media);
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
//    print("tap down " + x.toString() + ", " + y.toString());
    tapDownDetails = details;
  }

  ///处理点击弹起事件
  ///调用[calculateTapAction]方法以执行相应的功能
  void handleTapUp(TapUpDetails tapUpDetails) {
    var x = tapUpDetails.globalPosition.dx;
    var y = tapUpDetails.globalPosition.dy;
    calculateTapAction(
        tapDownDetails: tapDownDetails,
        tapUpDetails: tapUpDetails,
        size: new Size(pageWidth, pageHeight));
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
      handlePrevPage();
    } else if (x >= grid['x2']) {
      //下一页
      handleNextPage();
    } else {
      if (y <= grid['y1']) {
        //上一页
        handlePrevPage();
      } else if (y >= grid['y2']) {
        //下一页
        handleNextPage();
      } else {
        //打开菜单
        print('打开菜单');
        widget.handleShowMenu();
      }
    }
  }

  ///构建显示字块，它作为无限列表的元素显示
  ///调用[getSection]方法，获取第[index]的字块
  ///[getSection]是与[BookService]的桥梁
  Widget buildSections(BuildContext context, int index) {
    return new Section(
      content: getSection(index),
      style: bodyStyle,
    );
  }

  ///构建内容页面
  ///用于展示[Section]列表，此无限列表禁止手动划动
  ///通过[ScrollController]实现间断跳跃
  Widget buildPage() {
    if (pages.isEmpty) {
      pages.add(new ListView.builder(
          padding: const EdgeInsets.all(0.0),
          physics: scrollPhysics,
          controller: scrollController,
          itemBuilder: buildSections));
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
    currentPageNumber = widget.initialPageNumber;
    initReadMode();
    scrollController.addListener(handleScroll);
  }

  @override
  Widget build(BuildContext context) {
    print('build _PageState');
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
                    ),
                  ),
                ],
              ),
            ),
            new Expanded(
              child: new LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                pageHeight = constraints.maxHeight;
                pageWidth = constraints.maxWidth;
                print('View Size is H:$pageHeight,W:$pageWidth');
                return new Container(height: scrollHeight, child: buildPage());
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

    return new GestureDetector(
      child: new Container(
          decoration: new BoxDecoration(
              color: readMode?.backgroundColor ?? backgroundColor,
              image: readMode?.image),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      ),
                    ),
                  ],
                ),
              ),
              new Expanded(
                  child: new Container(
                child: new SingleChildScrollView(
                  child: new Text('hello world'),
                ),
//              child: new FutureBuilder(
//                  future: widget.text,
//                  builder:
//                      (BuildContext context, AsyncSnapshot<String> snapshot) {
//                    if (snapshot.connectionState == ConnectionState.done &&
//                        null != snapshot.data) {
//                      return new Text(
//                        snapshot.data,
//                        style: bodyStyle,
//                        softWrap: true,
//                        overflow: TextOverflow.clip,
//                        maxLines: 24,
//                      );
//                    } else {
//                      return new Container(
//                        child: new Center(
//                          child: new Text('读取中...'),
//                        ),
//                      );
//                    }
//                  }),
              )),
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
          )
//    child: new IconButton(icon: const Icon(Icons.message), onPressed: (){
//      print('messgae');
//    }),
          ),
    );
  }
}

class Section extends StatelessWidget {
  Section({@required this.content, @required this.style});

  final String content;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Text(
        content,
        style: style,
      ),
    );
  }
}
