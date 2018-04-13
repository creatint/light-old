import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Page extends StatefulWidget {
  Page({Key key, @required this.showMenu});

  final VoidCallback showMenu;

  @override
  PageState createState() => new PageState();
}

class PageState extends State<Page> {
  Size media;

  ///当前页码
  int pageNumber = 1;

  bool reverse = false;

  ///记录点击坐标详情
  TapDownDetails tapDownDetails;

  ///用于计算点击手势区域的比例
  Map<String, List<int>> tapRatio = <String, List<int>>{
    'x': [3, 4, 3],
    'y': [3, 4, 3]
  };

  ///点击手势区域坐标点
  Map<String, double> tapGrid = <String, double>{};

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

  ///[value]==true，下一页，[value]==false，上一页
  void handlePageChanged(bool next) {
    if (next) {
      print('下一页');
    } else {
      print('上一页');
    }
    print('Old pageNumber: $pageNumber');

    ///根据条件，对页码进行增一或减一
    if (!next) {
      if (reverse) {
        pageNumber++;
      } else {
        pageNumber--;
      }
    } else {
      if (reverse) {
        pageNumber--;
      } else {
        pageNumber++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build page');
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      media = new Size(constraints.maxWidth, constraints.maxHeight);
      print('media is $media');
      return new GestureDetector(
          onTapUp: handleTapUp,
          onTapDown: handleTapDown,
          child: new Container(
            color: Colors.white,
            child: new Center(child: new Text('h'
                'aslkdjfalksjf'
                'asdlkfjlkjf'
                'sdflkjsd'
                'sdflkj;slkdjf'
                'as;dlfkjaslkdjf'
                'aslkdjfalksjf'
                'asdlkfjlkjf'
                'sdflkjsd'
                'sdflkj;slkdjf'
                'as;dlfkjaslkdjf'
                'as;ldkfjasdlfjello world')),
          ));
    });
  }
}
