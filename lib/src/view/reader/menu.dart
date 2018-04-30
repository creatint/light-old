import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'setting_pannel.dart';
import 'package:light/src/widgets/item_button.dart';
import 'setting_list.dart';
import 'package:light/src/model/read_mode.dart';
import 'package:light/src/service/book_service.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/service/app_service.dart';
import 'package:light/src/widgets/custom_slider.dart';

enum Actions { list, mode, night, more }

class Menu extends StatefulWidget {
  Menu(
      {Key key,
      @required this.book,
      @required this.msgStream,
      @required this.handleSettings,
      @required this.readModeList,
      @required this.currentReadModeId});

  final Book book;
  final Stream msgStream;
  final HandleSettings handleSettings;
  final List<ReadMode> readModeList;
  final int currentReadModeId;

  @override
  MenuState createState() => new MenuState();
}

class MenuState extends State<Menu> {
  /// 服务
  AppService appService = new AppService();

  /// 订阅者，用于取消订阅
  StreamSubscription subscription;

  /// 消息流
  Stream bookDecoderStream;

  /// 分页实例
  Record record;

  /// 是否处于计算
  bool isCalculating = true;

  /// 分页是否计算完成
  bool isDone = false;

  /// 进度 0.0 - 100.0
  double process = 0.0;

  /// 是否显示底部默认导航栏
  bool showBottom = true;
  bool showHeader = true;

  /// 中部空白区域点击
  void onTapMiddle() {
    print('onTap@Menu');
    Navigator.pop(context);
  }

  ///
  void onTapMenu(int index) {
    print('onTapMenu $index');
  }

  /// 主题切换
  void handleModeChange() {
    print('handleModeChange');
  }

  /// 刷新进度
  void refreshProcess() {
    print('process = ${record.process}');
    setState(() {
      isCalculating = false;
      isDone = true;
      process = record.process;
    });
  }

  /// 处理进度改变
  void handleProcessChange(value) {
    print('process=$value index=${record.pageIndexFromProcess(value)}');
    appService.add(['record/jump', record.pageIndexFromProcess(value)]);
  }

  /// 上一章
  void prevChapter() {}

  /// 下一章
  void nextChapter() {}

  /// 处理分页计算进度
  void handleCalculateProcess() {
    if (null != Record.records) {
      refreshProcess();
    }
    bookDecoderStream = Record.receiveStream;
    if (null == bookDecoderStream) {
      print('没msgStream，退出');
      return;
    }
    subscription = bookDecoderStream.listen((value) {
      print('menu msg: $value');

      // 计算的进度消息
      if (value is Map && 'active' == value['state']) {
//        print('进度：${value['process']}%，'
//            '页码：${value['number']}，'
//            '长度：${value['length']}，'
//            '平均长度：${value['eveLength']}，'
//            '计算：${value['times']} 次，'
//            '总计算：${value['totalTimes']} 次，'
//            '平均计算：${value['aveTimes']} 次，'
//            '用时：${value['time']} ms，'
//            '平均用时 ${value['aveTime']} ms');
        setState(() {
          process = value['process'];
          isCalculating = true;
        });
      } else if (value is Map && 'done' == value['state']) {
        // 计算完成
//        print('计算完成，共 ${value['length']}字符，共 ${value['records'].length} '
//            '页，循环：${value['loopTimes']}次\n'
//            '总用时 ${value['time']} s '
//            '平均用时 ${value['aveTime']} ms\n'
//            '总计算 ${value['times']} 次 '
//            '平均计算 ${value['aveTimes']} 次');
        refreshProcess();
      }
    });
  }

  void handleMenu(Actions action) {
    switch (action) {
      case Actions.list:
        showHeader = false;
        showBottom = false;
        SystemChrome.setEnabledSystemUIOverlays([]);
        Navigator
            .push<bool>(
                context,
                new PageRouteBuilder<bool>(
                    opaque: false,
                    transitionDuration: const Duration(seconds: 0),
                    pageBuilder: (BuildContext context, _, __) {
                      return new Container(
                          child: new Row(
                        children: <Widget>[
                          new Expanded(
                              child: new Container(
                            color: Colors.white,
                            child: new Center(
                              child: new Text('目录'),
                            ),
                          )),
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context, true);
                            },
                            child: new Container(
                              color: Colors.black26,
                              width: 50.0,
                            ),
                          )
                        ],
                      ));
                    }))
            .then((value) {
//          Navigator.pop(context);
          showHeader = true;
          showBottom = true;
          SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        });
        break;
      case Actions.mode:
        Navigator
            .push<bool>(
                context,
                new PageRouteBuilder<bool>(
                    opaque: false,
                    transitionDuration: const Duration(seconds: 0),
                    pageBuilder: (BuildContext context, _, __) =>
                        new SettingPannel(
                          readModeList: widget.readModeList,
                          currentReadModeId: widget.currentReadModeId,
                          handleSettings: widget.handleSettings,
                        )))
            .then((bool value) {
          if (value == true) {
            Navigator.pop(context);
          } else {
            setState(() {
              showBottom = true;
            });
          }
        });
        setState(() {
          showBottom = false;
        });
        break;
      case Actions.night:
        break;
      case Actions.more:
        Navigator
            .push<bool>(
                context,
                new PageRouteBuilder<bool>(
                    opaque: false,
                    transitionDuration: const Duration(seconds: 0),
                    pageBuilder: (BuildContext context, _, __) =>
                        new SettingList()))
            .then((value) {});
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    print('initState@Menu');
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    handleCalculateProcess();
    record = new Record();
//    appService.stream.listen((value) {
//      if (value[0] == 'book/record') {
//
//      }
//    });
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose@Menu');
    SystemChrome.setEnabledSystemUIOverlays([]);
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _ktextStyle = new TextStyle(color: Colors.white70);
    return new Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          new Offstage(
            offstage: !showHeader,
            child: new AppBar(
              elevation: 0.0,
              backgroundColor: Colors.black87,
              leading: new IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context, true);
                  }),
            ),
          ),
          new Expanded(
              child: new GestureDetector(
                  onTap: onTapMiddle,
                  child: new Container(
                    color: Colors.black26,
                  ))),
          new Offstage(
            offstage: !showBottom,
            child: new Column(
              children: <Widget>[
                new Container(
                  padding:
                      const EdgeInsets.only(top: 24.0, left: 18.0, right: 18.0),
                  color: Colors.black87,
                  child: new Row(
                    children: <Widget>[
                      new Container(
                          width: 54.0,
                          child: new FlatButton(
                              padding: EdgeInsets.zero,
                              onPressed: isCalculating ? null : prevChapter,
                              child: new Text(
                                '上一章',
                                style: _ktextStyle,
                              ))),
                      new Expanded(
                        child: new CustomSlider(
                          value: process,
                          min: 0.0,
                          max: 100.0,
                          onChanged: isCalculating
                              ? null
                              : (double value) {
                                  setState(() {
                                    process = value;
                                  });
                                },
                          onEnded: (double value) {
                            print('onEnded value=$value');
                            handleProcessChange(process);
                          },
                        ),
                      ),
                      new Container(
                        width: 54.0,
                        child: new FlatButton(
                            padding: EdgeInsets.zero,
                            onPressed: isCalculating ? null : nextChapter,
                            child: new Text(
                              '下一章',
                              style: _ktextStyle,
                            )),
                      ),
                    ],
                  ),
                ),
                new Container(
                  padding:
                      const EdgeInsets.only(top: 5.0, left: 14.0, right: 14.0),
                  height: 65.0,
                  color: Colors.black87,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new ItemButton(
                        width: 48.0,
                        icon: const Icon(
                          Icons.list,
                          color: Colors.white70,
                        ),
                        title: const Text(
                          '目录',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          print('目录');
                          handleMenu(Actions.list);
                        },
                      ),
                      new ItemButton(
                        width: 48.0,
                        icon: const Icon(Icons.text_fields,
                            color: Colors.white70),
                        title: const Text('设置',
                            style: const TextStyle(color: Colors.white70)),
                        onTap: () {
                          handleMenu(Actions.mode);
                        },
                      ),
                      new ItemButton(
                        width: 48.0,
                        icon: const Icon(Icons.brightness_2,
                            color: Colors.white70),
                        title: const Text('夜间',
                            style: const TextStyle(color: Colors.white70)),
                        onTap: () {
                          handleMenu(Actions.night);
                        },
                      ),
                      new ItemButton(
                        width: 48.0,
                        icon:
                            const Icon(Icons.more_horiz, color: Colors.white70),
                        title: const Text('更多',
                            style: const TextStyle(color: Colors.white70)),
                        onTap: () {
                          handleMenu(Actions.more);
                        },
                      ),
                    ],
//        type: BottomNavigationBarType.fixed,
//        onTap: onTapMenu,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
