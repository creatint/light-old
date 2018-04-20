import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../parts/label.dart';
import '../parts/custom_button.dart';
import 'package:light/src/model/read_mode.dart';

enum Settings { fontSize, lineHeight, mode }

typedef void HandleSettings(Settings setting, dynamic);

class SettingPannel extends StatefulWidget {
  SettingPannel(
      {Key key,
      @required this.handleSettings,
      @required this.readModeList,
      @required this.currentReadModeId});

  final HandleSettings handleSettings;
  final List<ReadMode> readModeList;
  final int currentReadModeId;

  @override
  _SettingPannelState createState() =>
      new _SettingPannelState(currentReadModeId: currentReadModeId);
}

class _SettingPannelState extends State<SettingPannel> {
  _SettingPannelState({Key key, this.currentReadModeId});

  ///是否显示更多主题设置
  bool showMoreMode = false;
  int currentReadModeId;

  IndexedWidgetBuilder modeButtonBuilder(ReadModeType type) {
    List<ReadMode> list =
        widget.readModeList.where((mode) => mode.type == type).toList();
    return (BuildContext context, int index) {
      print(list[index]?.id);
      return buildModeButton(list[index]);
    };
  }

  Widget buildModeButton(ReadMode mode) {
    print('id=${mode.id} currentId=$currentReadModeId ${mode.id ==
        currentReadModeId}');
    print(mode.backgroundColor);
    return new Container(
      padding: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
      height: 48.0,
      width: 48.0,
      child: new CustomButton(
        active: mode.id == currentReadModeId,
        shape: const CircleBorder(),
        child: new Container(
          padding: const EdgeInsets.all(0.0),
          constraints: new BoxConstraints(maxHeight: 40.0, maxWidth: 40.0),
          margin: mode.id == currentReadModeId
              ? const EdgeInsets.all(3.0)
//            ? const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0)
//            ? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0)
              : null,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
//            borderRadius: mode.id == widget.currentReadModeId
//                ? new BorderRadius.all(new Radius.circular(15.0))
//                : null,
              color: mode.backgroundColor,
              image: mode.buttonImage),
        ),
        onPressed: () {
          handleSettings(Settings.mode, mode.id);
        },
      ),
    );
  }

  ///处理设置
  void handleSettings(Settings setting, dynamic value) {
    print('handleSettings@SettingPannel value=$value');
    switch (setting) {
      case Settings.mode:
        if (value >= 0) {
          setState(() {
            currentReadModeId = value;
          });
          widget.handleSettings(setting, value);
        }
        break;
      default:
    }
  }

  void handleShowMoreMode() {
    setState(() {
      showMoreMode = !showMoreMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showMoreMode
        ? new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Expanded(
                child: new GestureDetector(
                    onTap: () {
                      handleShowMoreMode();
                    },
                    child: new Container(
                      color: Colors.transparent,
                    )),
              ),
              new Container(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 16.0),
                  color: Colors.black87,
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Label(
                          title: '纯色',
                        ),
                        new Container(
                          constraints: new BoxConstraints(maxHeight: 60.0),
                          child: new GridView.builder(
                              key: new Key(currentReadModeId.toString()),
                              padding: const EdgeInsets.all(0.0),
                              gridDelegate:
                                  new SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 48.0),
                              itemCount: widget.readModeList
                                  .where(
                                      (mode) => mode.type == ReadModeType.color)
                                  .toList()
                                  .length,
                              itemBuilder:
                                  modeButtonBuilder(ReadModeType.color)),
                        ),
                        new Label(
                          title: '纹理',
                        ),
                        new Container(
                          constraints: new BoxConstraints(maxHeight: 50.0),
                          child: new GridView.builder(
                              key: new Key(currentReadModeId.toString()),
                              padding: const EdgeInsets.all(0.0),
                              gridDelegate:
                                  new SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 48.0),
                              itemCount: widget.readModeList
                                  .where((mode) =>
                                      mode.type == ReadModeType.texture)
                                  .toList()
                                  .length,
                              itemBuilder:
                                  modeButtonBuilder(ReadModeType.texture)),
                        ),
                        new Label(
                          title: '图片',
                        ),
                        new Container(
                          constraints: new BoxConstraints(maxHeight: 50.0),
                          child: new GridView.builder(
                              key: new Key(currentReadModeId.toString()),
                              padding: const EdgeInsets.all(0.0),
                              gridDelegate:
                                  new SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 48.0),
                              itemCount: widget.readModeList
                                  .where(
                                      (mode) => mode.type == ReadModeType.image)
                                  .toList()
                                  .length,
                              itemBuilder:
                                  modeButtonBuilder(ReadModeType.image)),
                        )
                      ])),
            ],
          )
        : new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Expanded(
                  child: new GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: new Container(
                        color: Colors.transparent,
                      ))),
              new Container(
                padding: const EdgeInsets.only(
                    top: 16.0, left: 8.0, right: 16.0, bottom: 16.0),
                color: Colors.black87,
                child: new Column(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new Label(title: '字号'),
                        new Expanded(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Expanded(
                                child: new CustomButton(
                                  width: double.infinity,
                                  title: '小',
                                  onPressed: () {
                                    widget.handleSettings(
                                        Settings.fontSize, -2);
                                  },
                                ),
                              ),
                              new Expanded(
                                child: new CustomButton(
                                  width: double.infinity,
                                  title: '大',
                                  onPressed: () {
                                    widget.handleSettings(Settings.fontSize, 2);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    new Row(
                      children: <Widget>[
                        new Label(title: '行距'),
                        new Expanded(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new CustomButton(
                                active: true,
                                shape: const CircleBorder(),
                                iconData: Icons.format_align_justify,
                                onPressed: () {
                                  widget.handleSettings(Settings.lineHeight, 2);
                                },
                              ),
                              new CustomButton(
                                shape: const CircleBorder(),
                                iconData: Icons.view_headline,
                                onPressed: () {
                                  widget.handleSettings(Settings.fontSize, 2);
                                },
                              ),
                              new CustomButton(
                                shape: const CircleBorder(),
                                iconData: Icons.menu,
                                onPressed: () {
                                  widget.handleSettings(Settings.fontSize, 2);
                                },
                              ),
                              new CustomButton(
                                shape: const CircleBorder(),
                                iconData: Icons.drag_handle,
                                onPressed: () {
                                  widget.handleSettings(Settings.fontSize, 2);
                                },
                              ),
                              new CustomButton(
                                shape: const CircleBorder(),
                                iconData: Icons.remove,
                                onPressed: () {
                                  widget.handleSettings(Settings.fontSize, 2);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    new Row(
                      children: <Widget>[
                        new Label(title: '背景'),
                        new Expanded(
                          child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: widget.readModeList
                                  .sublist(0, 4)
                                  .map((mode) => buildModeButton(mode))
                                  .toList()
                                    ..add(new CustomButton(
                                      shape: const CircleBorder(),
                                      borderColor: Colors.transparent,
                                      iconData: Icons.more_horiz,
                                      onPressed: handleShowMoreMode,
                                    ))),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
  }
}
