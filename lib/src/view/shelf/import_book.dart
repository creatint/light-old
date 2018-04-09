import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:light/src/service/file_service.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/view/reader/reader.dart';
import 'package:light/src/service/book_service.dart';
import 'package:light/src/view/custom_page_route.dart';
import 'package:light/src/view/custom_indicator.dart';
import 'package:light/src/view/shelf/entity_item.dart';
import 'package:light/src/parts/select_bottom_bar.dart';
import 'package:light/src/parts/selected_list_model.dart';

enum DialogAction { requestForPermission }

class ImportBook extends StatefulWidget {
  ImportBook({Key key, this.path, this.isRoot: false, @required this.prefs})
      : super(key: key);
  final String path;
  final isRoot;
  final SharedPreferences prefs;

  @override
  ImportBookState createState() => new ImportBookState();
}

class ImportBookState extends State<ImportBook> {
  static const platform = const MethodChannel('light.yotaku.cn/system');
  static final BookService bookService = new BookService();
  bool isLoading = true;
  bool inSelect = false; //是否是选择模式
  bool isSelectFolders = false; //是否是文件夹选择模式
  List<FileSystemEntity> entityList = <FileSystemEntity>[]; //当前显示条目
  SelectedListModel<FileSystemEntity> selectedEntities; //已选择条目
  List<Directory> directoryStack = <Directory>[]; //链接栈

  Future<Null> _handleOpenApplicationSettings() async {
    try {
      await platform.invokeMethod('openApplicationSettings');
    } on PlatformException catch (e) {
      print('openApplicationSettings Error: ${e.message}');
    }
  }

  ///
  void initPath([String path]) async {
    if (path == null) {
      directoryStack.add(await getExternalStorageDirectory());
    } else {
      if (directoryStack.isNotEmpty && path != directoryStack.last.path) {
        directoryStack.add(new Directory(path));
      } else if (directoryStack.isEmpty) {
        directoryStack.add(new Directory(path));
      }
    }
    setState(() {});
    handlePathChange(directoryStack.last);
  }

  ///处理当前路径改变事件
  void handlePathChange(Directory directory) {
    print('handlePathChange = ${directory.path}');
    print(directoryStack);
    bool isDir = FileSystemEntity.isDirectorySync(directory.path);
    if (isDir) {
      //是文件夹
      print(' 是文件夹');
      try {
        setState(() {
          entityList.clear();
        });
        directory.listSync().forEach((entity) {
          if (isDirectory(entity) || isBook(entity)) {
            setState(() {
              entityList.add(entity);
            });
          }
        });
      } on FileSystemException catch (e) {
        print('Error: $e');
        final ThemeData theme = Theme.of(context);
        final TextStyle dialogTextStyle = theme.textTheme.subhead
            .copyWith(color: theme.textTheme.caption.color);
        showDialog<bool>(
            context: context,
            child: new AlertDialog(
                title: const Text('权限不足'),
                content: new Text('浏览文件需要文件读取权限，是否跳转到Light设置页面？',
                    style: dialogTextStyle),
                actions: <Widget>[
                  new FlatButton(
                      child: const Text('拒绝'),
                      onPressed: () {
                        Navigator.pop(context, false);
                      }),
                  new FlatButton(
                      child: const Text('同意'),
                      onPressed: () {
                        Navigator.pop(context, true);
                      })
                ])).then<bool>((value) {
          print(value);
          if (true == value) {
            _handleOpenApplicationSettings();
            Navigator.pop(context);
          }
        });
      } catch (e) {
        print('Unknown Error: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('path change: 是文件');
    }
  }

  ///处理条目点击事件
  void handleEntityTap(FileSystemEntity entity) {
    print('handleEntityTap 点击了 ' + entity.path);
    if (inSelect) {
      setState(() {
        if (selectedEntities.indexOf(entity) >= 0) {
          selectedEntities.remove(entity);
        } else {
          selectedEntities.add(entity);
        }
      });
      print(selectedEntities.indexOf(entity));
    } else {
      bool isDir = FileSystemEntity.isDirectorySync(entity.path);
      if (isDir) {
        directoryStack.add(entity);
        handlePathChange(entity);
      } else {
        //判断类型，如果是电子书则,则判断数据库中是否存在，
        // 不存在则自动增加到数据库
        // 打开文件
        print('handle tap 是文件 ${entity.path}');
        bookService.addLocalBook(entity.path);
        Book book = new Book.fromEntity(entity: entity);
        Navigator.push(context,
            new CustomPageRoute(builder: (context) => new Reader(book: book, prefs: widget.prefs,)));
      }
    }
  }

  ///处理长按
  void handleLongPress({FileSystemEntity entity, FileType type}) {
    print('handleLongPress: ${entity.path} type: $type');
    if (FileType.DIRECTORY == type) {
      setState(() {
        isSelectFolders = true;
      });
    } else {
      setState(() {
        isSelectFolders = false;
      });
    }
    if (!inSelect) {
      setState(() {
        selectedEntities.add(entity); //TODO:去重
        inSelect = true;
      });
      print(selectedEntities);
    }
  }

  ///SelectedListModel所用移除元素方法
  void handleRemove(FileSystemEntity entity, List<FileSystemEntity> list) {
    if (list.length == 0) return;
    list.removeWhere((FileSystemEntity tmp) {
      return tmp.path == entity.path;
    });
  }

  ///SelectedListModel所用查询索引方法
  int handleIndexOf(FileSystemEntity entity, List<FileSystemEntity> list) {
    if (list.length == 0) return -1;
    return list.indexWhere((FileSystemEntity tmp) {
      return tmp.path == entity.path;
    });
  }

  void handleSelectAll() {
    if (selectedEntities.length >= entityList.length) {
      setState(() {
        selectedEntities.clear();
      });
    } else {
      selectedEntities.clear();
      setState(() {
        selectedEntities.addAll(entityList);
      });
    }
  }

  ///处理导入事件
  void handleImport() async {
    print('import books: ${selectedEntities.length}');
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subhead;
    int num = await bookService.addLocalBooks(selectedEntities);
    print('imported $num books');
    showDialog<bool>(
        context: context,
        child: new AlertDialog(
            title: new Text(num > 0 ? '成功导入${num}个资源' : '导入失败'),
            content: new Text('返回书架？', style: dialogTextStyle),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('否'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  }),
              new FlatButton(
                  child: const Text('是'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  })
            ])).then<bool>((value) {
      print(value);
      if (value) {
        Navigator.pop(context);
      } else {
//          handleCancleSelect();
      }
    });
  }

  ///取消选择模式
  void handleCancleSelect() {
    setState(() {
      selectedEntities.clear();
      inSelect = false;
      entityList.clear();
    });
    initPath(directoryStack.last.path);
  }

  ///处理扫描事件
  void handleScan([FileSystemEntity entity]) {
    print('scan folders: ${selectedEntities.length} , ${entity.path}');
    setState(() {
      inSelect = true;
      entityList.clear();
      isLoading = true;
    });
    new Timer(const Duration(milliseconds: 200), () {
      if (null != entity) {
        doScan(entity);
      } else {
        selectedEntities.forEach((FileSystemEntity entity) {
          doScan(entity);
        });
      }
      setState(() {
        isSelectFolders = false;
        selectedEntities.clear();
        isLoading = false;
      });
    });
  }

  void doScan(FileSystemEntity entity) {
    if (FileSystemEntity.isDirectorySync(entity.path)) {
      Directory dir = new Directory(entity.path);
      dir.listSync(recursive: true).forEach((FileSystemEntity entity) {
//        recursiveScan(entity);
        if (isBook(entity)) {
          setState(() {
            entityList.add(entity);
          });
        }
      });
    }
  }

  ///构建AppBar
  Widget buildAppBar() {
    return new AppBar(
      title: new Text('导入本地图书'),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              handleScan(directoryStack.last);
            },
            child: new Text(
              '扫描',
              style: Theme.of(context).textTheme.subhead.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Colors.white70),
            ))
      ],
    );
  }

  ///构建路径显示栏
  Widget buildPathBar() {
    return new Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: new Offstage(
                offstage: directoryStack.isEmpty,
                child: new Text(
                  directoryStack.isEmpty ? 'empty' : directoryStack.last.path,
//                  'asdf',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            new Offstage(
                offstage: directoryStack.length < 2,
                child: new SizedBox(
                  height: 44.0,
                  child: new FlatButton(
                      child: new Text('上一级'),
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        print('上级菜单');
                        directoryStack.removeLast();
                        handlePathChange(directoryStack.last);
                      }),
                ))
          ],
        ));
  }

  ///构建文件(夹)条目
  Widget buildEntities() {
    if (entityList != null && entityList.length > 0) {
      return new ListView.builder(
        padding: new EdgeInsets.all(8.0),
        shrinkWrap: true,
//        itemExtent: 20.0,
        itemCount: entityList.length,
        itemBuilder: (BuildContext context, int index) {
          return new EntityItem(
            key: new Key('ha'),
            inSelect: inSelect,
            entity: entityList[index],
            selectedEntities: selectedEntities,
//              type: getType(getBasename(entityList[index].path)),
            onTap: handleEntityTap,
            onLongPress: handleLongPress,
          );
        },
      );
    }
    return new Center(child: new Text('无资源'));
  }

  ///构建过场动画
  Widget buildIndicator() {
    return new CustomIndicator();
  }

  ///构建当前页面
  Widget buildContent() {
    if (isLoading) {
      return buildIndicator();
    } else {
      return buildEntities();
    }
  }

  ///构建选择模式底部组件
  Widget buildBottomBar() {
    return new SelectBottomBar(
      selectedList: selectedEntities,
      list: entityList,
      handleSelectAll: handleSelectAll,
      handleCancel: handleCancleSelect,
      handleEnter: isSelectFolders ? handleScan : handleImport,
      buttonText: isSelectFolders ? '扫描' : '导入',
    );
  }

  @override
  void initState() {
    super.initState();
    print('initState');
    selectedEntities = new SelectedListModel(
        handleIndexOf: handleIndexOf, handleRemove: handleRemove);
    initPath(widget.path);
    //test
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(),
      body: new Column(
        children: <Widget>[
          new Container(
            height: 44.0,
            decoration: new BoxDecoration(
                border: new Border(
                    bottom: new BorderSide(
                        color: Theme.of(context).dividerColor, width: 1.0))),
            child: buildPathBar(),
          ),
          new Expanded(child: new Scrollbar(child: buildContent())),
          new Offstage(
            offstage: !inSelect,
            child: new Column(
                children: <Widget>[new Divider(height: 1.0), buildBottomBar()]),
          )
        ],
      ),
    );
  }
}
