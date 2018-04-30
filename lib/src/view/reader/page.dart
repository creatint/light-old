import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:light/src/model/read_mode.dart';
import 'package:light/src/service/book_service.dart';
import 'package:light/src/utils/page_calculator.dart';
import 'package:light/src/utils/custom_text_painter.dart';
import 'package:light/src/service/app_service.dart';

///
/// 错误代码：
/// 001E2: 实例化BookDecoder失败
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
  final ValueGetter<Future<bool>> showMenu;

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
  /// App服务实例
  AppService appService = new AppService();

  /// 监听页面跳转订阅者
  StreamSubscription subscriptionJump;

  /// 监听分页计算完毕订阅者
  StreamSubscription subscriptionDone;

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
  Size _mediaSize;

  ///文字显示尺寸
  Size pageSize;

  ///当前页码
  int pageNumber;

  /// 浏览页码的最大值
  /// 用于计算页面数量
  int maxPageNumber = 0;

  ///旧页码
  int oldPageNumber = 0;

  ///最大显示行数，需要计算
  int _maxLines = 13;

  ///字块长度
  int sectionSize = 450;

  ///字块偏移值
  int sectionOffset = 0;

  /// 最后字符的偏移
  int lastOffset = 0;

  /// 书籍字符长度
  int _maxLength;

  ///是否倒序翻页
  bool reverse = false;

  ///记录点击坐标详情
  TapDownDetails tapDownDetails;

  ///内容
  Section section;

  /// 分页数量
  int childCount = 1;

  /// 用于计算点击手势区域的比例
  Map<String, List<int>> tapRatio = <String, List<int>>{
    'x': [1, 1, 1],
    'y': [1, 1, 1]
  };

  /// 点击手势区域坐标点
  Map<String, double> tapGrid = <String, double>{};

  /// 阅读记录
//  Map<int, List<int>> records = <int, List<int>>{};

  /// 阅读记录
  Record records;

  /// 分页计算状态
  bool isCalculating = true;

  /// 是否正在显示菜单
  bool isShowMenu = false;

  /// 计算总次数
  int times = 0;

  /// 书籍内容最大长度
  int get maxLength {
    if (null != bookDecoder) {
      if (null == _maxLength) {
        _maxLength = bookDecoder.maxLength;
      }
    }
    return _maxLength;
  }

  /// 设置媒体尺寸，同时更新pageSize和pageCalculator
  set mediaSize(Size size) {
    if (size != _mediaSize) {
      _mediaSize = size;
      pageSize = _mediaSize - new Offset(40.0, 60.0);
      pageCalculator.pageSize = pageSize;
      _maxLines = null;
      pageCalculator.maxLines = maxLines;
    }
  }

  /// 获取媒体尺寸
  Size get mediaSize => _mediaSize;

  ///处理屏幕改变事件
  void handleMediaChange(Size size) {
    if (mediaSize != size) {
      mediaSize = size;
      print('mediaSize changed,is $mediaSize');
    }
  }

  ///处理点击事件
  void handleTapDown(TapDownDetails details) {
    tapDownDetails = details;
  }

  /// 处理点击弹起事件
  /// 用于切换页面、打开菜单
  void handleTapUp(TapUpDetails tapUpDetails) {
    double x = tapUpDetails.globalPosition.dx;
    double y = tapUpDetails.globalPosition.dy;
    if (tapGrid.isEmpty) {
      double x1 = mediaSize.width *
          (tapRatio['x'][0] /
              (tapRatio['x'][0] + tapRatio['x'][1] + tapRatio['x'][2]));
      double x2 = mediaSize.width *
          ((tapRatio['x'][0] + tapRatio['x'][1]) /
              (tapRatio['x'][0] + tapRatio['x'][1] + tapRatio['x'][2]));
      double y1 = mediaSize.height *
          (tapRatio['y'][0] /
              (tapRatio['y'][0] + tapRatio['y'][1] + tapRatio['y'][2]));
      double y2 = mediaSize.height *
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
        isShowMenu = true;
        widget.showMenu().then((value) {
          if (true == value) {
            // 弹出菜单，调用record.reset
            records.reset(
                book: bookDecoder.book,
                pageSize: pageSize,
                textStyle: widget.textStyle,
                textAlign: widget.textAlign,
                textDirection: widget.textDirection,
                maxLines: maxLines,
                callback: handleCountChange);
            isShowMenu = false;
          }
        });
      }
    }
  }

  /// 是否有下一页
  bool get hasNextPage => lastOffset < maxLength;

  ///标题样式的获取
  TextStyle get titleStyle => Theme
      .of(context)
      .textTheme
      .title
      .copyWith(fontSize: 14.0, color: Theme.of(context).disabledColor);

  /// 计算每页显示行数
  int get maxLines {
    if (null == _maxLines) {
      double lineHeight =
          1.1667 * widget.textStyle.fontSize * widget.textStyle.height;
      _maxLines = pageSize.height ~/ lineHeight;
    }
    return _maxLines;
  }

  ///获取标题
  String get title {
    return section?.title ?? bookDecoder?.book?.title ?? '';
  }

  /// 分页计算完毕，设置页面数量
  void handleCountChange(int count) {
    print('handleCountChange count=$count');
    setState(() {
      childCount = count;
      isCalculating = false;
    });
  }

  /// 每次切换
  /// 会造成页面刷新
  void handlePageScroll() {
//    print('handlePageScroll controller.page=${controller.page}\n'
//        'childCount=$childCount maxPageNumber=$maxPageNumber');
    if (!isCalculating) {
      return;
    }
    if (controller.page == null || controller.page % 1 == 0.0) {
      /// 刷新将要浏览的最大页码
      if (maxPageNumber < (controller.page).round()) {
        maxPageNumber = (controller.page).round();
      }
      int count = childCount;
//      print('flag count=$count');
      if (hasNextPage) {
        count = maxPageNumber + 2;
//        print('flag1 count=$count');
      }
      if (count > childCount)
        setState(() {
          childCount = count;
        });
    }
//    print('childCount = $childCount');
  }

  /// 页码切换
  /// next=true: 下一页
  /// next=false: 上一页
  void handlePageChanged(bool next) {
    if (next) {
      // 下一页
//      print('下一页');
      if (!hasNextPage) {
        print('最后一页了');
        return;
      }

      controller.nextPage(
          duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
    } else {
      // 上一页
//      print('上一页');
      controller.previousPage(
          duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
    }
  }

  ///根据偏移值获取字块
  ///无内容则返回null
  Section getSection(int offset, [int length]) {
    section =
        bookDecoder.getSection(offset: offset, length: length ?? sectionSize);
//    print('section.isLast=${section.isLast}');
    if (null != section && section.isNotEmpty) {
      return section;
    }
    return null;
  }

  // 构建内容页面
  Widget buildContent(int index) {
    print('buildContent@Page index=$index');

    // 更新当前阅读偏移
    records.currentIndex = index;

    // 页码非当前页，则计算页码，否则直接显示当前页
    if (index != pageNumber || null == pageNumber) {
      pageNumber = index;

      ///存在当前分页数据，直接获取内容
      if (null != records[index]) {
        print('分页(1)：${records[index]}');
        pageCalculator
            .layout(getSection(records[index][0], records[index][1]).text);
      } else if (null != records[index - 1]) {
        ///存在上一页面数据,获取下一页内容
        /// 计算下一页偏移值
        print('计算下一页偏移值');
        int offset = records[index - 1][0] + records[index - 1][1];
        // 最大循环100次，正常情况下10次左右
        for (int i = 1; i < 100; i++) {
          print('flag');
          Section section = getSection(offset, sectionSize * i);
          print(section);
          if (null == section) {
            pageCalculator.load('无内容');
            break;
          } else if (pageCalculator.load(section.text)) {
            records[index] = [offset, pageCalculator.length];
            print('分页(2)：${records[index]}');
            break;
          }
        }
        times += pageCalculator.times;
//        print('计算 ${pageCalculator.times} 次\n'
//            '平均每页计算 ${times / (index + 1) * 10 ~/ 1 / 10}\n'
//            '共计算 $times 次');
        pageCalculator.times = 0;
      } else {
        for (int i = 1; i < 100; i++) {
          Section section = getSection(sectionOffset, sectionSize * i);
          if (null == section) {
            pageCalculator.load('读取文件失败：001E3\nBookDecoder=null');
            break;
          }
          if (section.isLast == true) {
            pageCalculator.load(section.text);
            records[index] = [sectionOffset, pageCalculator.length];
            print('分页(3.1)：${records[index]}');
            break;
          } else if (pageCalculator.load(section.text)) {
            records[index] = [sectionOffset, pageCalculator.length];
            print([sectionOffset, pageCalculator.length]);
            print('index=$index');
            print('records $records');
            print('分页(3.2)：${records[index]}');
            break;
          }
        }

        /// 统计计算次数
        times += pageCalculator.times;
//        print('计算 ${pageCalculator.times} 次\n'
//            '平均每页计算 ${times / (index + 1) * 10 ~/ 1 / 10}\n'
//            '共计算 $times 次');

        /// 重置计算次数为0
        pageCalculator.times = 0;

        /// 更新最后字符的偏移
        lastOffset = records[index][0] + records[index][1];

        /// 刷新分页数量
        /// 会造成页面刷新一次
        new Future.microtask(() {
          handlePageScroll();
        });
      }
    }

    // 更新最后字符的偏移
    if (null != records[index]) {
      lastOffset = records[index][0] + records[index][1];
    }

    /// 用Text显示内容
    /// 内容可能会超过可视区域
    /// 用maxLines限制内容行数
    return new Text(
      pageCalculator.content,
      style: widget.textStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      maxLines: maxLines,
    );
  }

  Widget pageBuilder(BuildContext context, int index) {
    print('pageBuilder@Page index=$index oldPageNumber=$pageNumber');
    print('childCount=$childCount');

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
                  title,
                  style: titleStyle,
                )),
              ],
            ),
          ),
          new Expanded(
            child: buildContent(index),
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

    /// 阅读记录实例
    records = new Record(prefs: widget.prefs);

    /// 翻页控制器
    controller = new PageController();

    /// 监听页面滚动事件
    controller.addListener(handlePageScroll);

    /// 分页计算器
    pageCalculator = new PageCalculator(
        key: 'page',
        textStyle: widget.textStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection);

    /// 页面绘制器
//    painter = new CustomTextPainter(textPainter: pageCalculator.textPainter);

    /// 监听页面跳转事件
    subscriptionJump = appService.stream.listen((value) {
      print('stream $value');
      if ('record/jump' == value[0] && value[1] >= 0) {
        controller.jumpToPage(value[1]);
      }
    });

    /// 如果存在则直接更新
    if (null != Record.records) {
      childCount = Record.records.length;
      print('更新childCount=$childCount');
    }

    /// 监听分页计算完毕事件
    subscriptionDone = Record.receiveStream.listen((value) {
      if (value is Map && 'done' == value['state']) {
        setState(() {
          childCount = value['records'].length;
          print('刷新childCount=$childCount');
        });
      }
    });
  }

  /// 初始化书记资源、分页数据等
  void initial() {
    // 显示菜单时不刷新整书分页
    if (!isShowMenu)
      records.reset(
          book: bookDecoder.book,
          pageSize: pageSize,
          textStyle: widget.textStyle,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          maxLines: maxLines,
          callback: handleCountChange);
//    controller.jumpToPage(records.c)
  }

  @override
  Widget build(BuildContext context) {
//    print('build@Page');
    return new Scaffold(
      body: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          handleMediaChange(
              new Size(constraints.maxWidth, constraints.maxHeight));
          return new FutureBuilder(
              future: widget.bookDecoderFuture,
              builder:
                  (BuildContext context, AsyncSnapshot<BookDecoder> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return new Center(child: new Text('读取中...'));
                } else if (snapshot.connectionState == ConnectionState.done &&
                    !snapshot.hasError &&
                    snapshot.hasData) {
                  bookDecoder = snapshot.data;
                  /// 初始化
                  initial();
                  return GestureDetector(
                    onTapUp: handleTapUp,
                    onTapDown: handleTapDown,
                    child: new PageView.custom(
                      key: new Key(widget.currentReadModeId.toString()),
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      childrenDelegate: new SliverChildBuilderDelegate(
                          pageBuilder,
                          childCount: childCount,
                          addRepaintBoundaries: false,
                          addAutomaticKeepAlives: false),
                    ),
                  );
                } else {
                  String err = 'Oops！错误代码：001E2\n${snapshot.error}';
                  return new Center(child: new Text(err));
                }
              });
        },
      ),
    );
  }

  @override
  void dispose() {
    records?.close();
    super.dispose();
    subscriptionJump?.cancel();
    subscriptionDone?.cancel();
  }
}
