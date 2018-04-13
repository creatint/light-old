import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
//import 'dart:async';

import 'package:light/src/service/file_service.dart';
import 'package:light/src/parts/selected_list_model.dart';

typedef void LongPress({FileSystemEntity entity, FileType type});

class EntityItem extends StatefulWidget {
  EntityItem(
      {Key key,
      @required this.entity,
      @required this.onTap,
      @required this.onLongPress,
      @required this.selectedEntities,
      @required this.inSelect})
      : super(key: key);

  final FileSystemEntity entity;
  final ValueChanged<FileSystemEntity> onTap;

//  final ValueChanged<FileSystemEntity> onLongPress;
  final LongPress onLongPress;
  final SelectedListModel<FileSystemEntity> selectedEntities;
  final inSelect;

  @override
  EntityItemState createState() => new EntityItemState();
}

class EntityItemState extends State<EntityItem> {
  FileType type;

  ///检查是否选中
  bool checkSelected() {
    if (widget.selectedEntities.indexOf(widget.entity) >= 0) return true;
    return false;
  }

  ///获取选中图标高亮颜色
  Color getColor() {
    if (checkSelected()) {
      return Theme.of(context).accentColor;
    }
    return Theme.of(context).disabledColor;
  }

  ///构建头部图标
  Icon buildLeadingIcon() {
    type = getType(widget.entity);
    IconData data;
    switch (type) {
      case FileType.TEXT:
      case FileType.PDF:
      case FileType.EPUB:
        data = Icons.book;
        break;
      case FileType.OTHER:
        data = Icons.insert_drive_file;
        break;
      case FileType.DIRECTORY:
        data = Icons.folder;
        break;
      case FileType.NOT_FOUND:
      default:
        data = Icons.do_not_disturb;
    }
    return new Icon(data);
  }

  ///构建尾部图标
  Icon buildTailIcon() {
    if (checkSelected()) {
      return new Icon(
        Icons.check_circle,
        color: getColor(),
      );
    }
    return new Icon(
      Icons.radio_button_unchecked,
      color: getColor(),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new DecoratedBox(
        decoration: new BoxDecoration(
            border: new Border(
                bottom: new BorderSide(color: Colors.grey[200], width: 1.0))),
        child: new ListTile(
            onTap: () {
              widget.onTap(widget.entity);
            },
            onLongPress: () {
              widget.onLongPress(
                  entity: widget.entity, type: getType(widget.entity));
            },
            leading: buildLeadingIcon(),
            title: new Text(
              getBasename(widget.entity.path),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: new Offstage(
              offstage: !widget.inSelect,
              child: buildTailIcon(),
            )));
  }
}

class CustomIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    return new Container(
      margin: const EdgeInsets.all(11.0),
      width: 1.0,
      height: 1.0,
      color: iconTheme.color,
    );
  }
}
