import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'setting_pannel.dart';
import '../parts/item_button.dart';
import 'setting_list.dart';
import 'package:light/src/model/read_mode.dart';

enum Actions { list, mode, night, more }

class Menu extends StatefulWidget {
  Menu(
      {Key key,
      @required this.handleSettings,
      @required this.readModeList,
      @required this.currentReadModeId});

  final HandleSettings handleSettings;
  final List<ReadMode> readModeList;
  final int currentReadModeId;

  @override
  MenuState createState() => new MenuState();
}

class MenuState extends State<Menu> {
  ///是否显示底部默认导航栏
  bool showBottom = true;
  bool showHeader = true;

  void onTapMiddle() {
    print('onTap@Menu');
    Navigator.pop(context);
  }

  void onTapMenu(int index) {
    print('onTapMenu $index');
  }

  void handleModeChange() {
    print('handleModeChange');
  }

  void handleSettings(Settings setting, dynamic value) {}

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
                          handleSettings: handleSettings,
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
            .then((value) {
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    print('initState@Menu');
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose@Menu');
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: Theme.of(context).copyWith(buttonColor: Colors.orange),
      child: new Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            new Offstage(
              offstage: !showHeader,
              child: new AppBar(
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
              child: new Container(
                padding: const EdgeInsets.only(top: 5.0),
                height: 65.0,
                color: Colors.black87,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new ItemButton(
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
                      icon:
                          const Icon(Icons.text_fields, color: Colors.white70),
                      title: const Text('设置',
                          style: const TextStyle(color: Colors.white70)),
                      onTap: () {
                        handleMenu(Actions.mode);
                      },
                    ),
                    new ItemButton(
                      icon:
                          const Icon(Icons.brightness_2, color: Colors.white70),
                      title: const Text('夜间',
                          style: const TextStyle(color: Colors.white70)),
                      onTap: () {
                        handleMenu(Actions.night);
                      },
                    ),
                    new ItemButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white70),
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
            )
          ],
        ),
      ),
    );
  }
}
