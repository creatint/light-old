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

  //初始化主题
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

  ///获取sectionSize长度的字块
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

  void handleScroll() {
    print('Scrolled.');
    ScrollPosition position = scrollController.position;
    print('offset: ${position.pixels}');
    print('maxExtent: ${position.maxScrollExtent}');
    if ((position.maxScrollExtent - position.pixels) <= pageHeight * 2) {
      print('handleScroll: 获取内容');
      setState(() {
        list.add(getSection(currentSectionNumber));
      });
    }
  }

  ///上一页
  void handlePrevPage() {
    print('上一页');
    ScrollPosition position = scrollController.position;
//    print(position);
    double maxScrollExtent = position.maxScrollExtent;
    double offset = position.pixels;
    print('pageHeight: $pageHeight');
    print('currentPageNumber: $currentPageNumber');
    if (currentPageNumber <= 2) {
      currentPageNumber = 1;
    } else {
      currentPageNumber--;
    }
    double y = pageHeight * (currentPageNumber - 1);
    print('want up to $y');
    print('offset: $offset');
    print('max: $maxScrollExtent');
    position.animateTo(y,
        duration: const Duration(microseconds: 1), curve: Curves.linear);
  }

  ///下一页
  void handleNextPage() {
    print('下一页');
    ScrollPosition position = scrollController.position;
//    print(position);
    double maxScrollExtent = position.maxScrollExtent;
    double offset = position.pixels;
    print('pageHeight: $pageHeight');
    print('currentPageNumber: $currentPageNumber');
    currentPageNumber++;
    double y = pageHeight * (currentPageNumber - 1);
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

  void handleTapUp(TapUpDetails tapUpDetails) {
    var x = tapUpDetails.globalPosition.dx;
    var y = tapUpDetails.globalPosition.dy;
    calculateTapAction(
        tapDownDetails: tapDownDetails,
        tapUpDetails: tapUpDetails,
        size: new Size(pageWidth, pageHeight));
  }

  ///计算点击操作
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
//    print(grid);
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

  Widget buildSections(BuildContext context, int index) {
    return new Section(
      content: getSection(index),
    );
  }

  ///构建页面
  Widget buildPage() {
    if (pages.isEmpty) {
//      String section = getSection(currentSectionNumber);
//      list.add(section);
//      pages.add(new SingleChildScrollView(
//        controller: scrollController,
//        physics: scrollPhysics,
//        child: new Column(
//          children: list.map((String section) {
//            return new ContentItem(item: section);
//          }).toList(),
//        ),
//      ));
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

  TextStyle get titleStyle => Theme
      .of(context)
      .textTheme
      .title
      .copyWith(fontSize: 14.0, color: Theme.of(context).disabledColor);

  TextStyle get bodyStyle => new TextStyle(
      color: readMode?.fontColor ?? fontColor,
      fontSize: fontSize,
      height: fontHeight);

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
            left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
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
                return buildPage();
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
    return new Text('hello world');

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
  Section({@required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return new Container(
//      color: Colors
//          .primaries[new Random().nextInt(1000) % Colors.primaries.length],
      child: new Text(content),
    );
  }
}
