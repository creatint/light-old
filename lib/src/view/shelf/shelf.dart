import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:light/src/service/book_service.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/view/search/search.dart';
import 'package:light/src/widgets/custom_page_route.dart';
import 'package:light/src/view/shelf/import_book.dart';
import 'package:light/src/view/shelf/book_item.dart';
import 'package:light/src/view/reader/reader.dart';
import 'package:light/src/model/selected_list_model.dart';

class Shelf extends StatefulWidget {
  Shelf(
      {@required Key key,
      @required this.useLightTheme,
      @required this.prefs,
      @required this.onThemeChanged,
      @required this.showReadProgress,
      @required this.hideBottom})
      : super(key: key);
  final bool useLightTheme;
  final SharedPreferences prefs;
  final bool showReadProgress;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> hideBottom;

  @override
  _ShelfState createState() => new _ShelfState();
}

enum Actions { import, changeTheme, edit }

class _ShelfState extends State<Shelf> {
  /// 当前Book列表
  List<Book> books = <Book>[];

  /// 服务
  BookService bookService = new BookService();

  /// 选中的Book列表
  SelectedListModel<Book> selectedBooks;

  //是否是选择模式
  bool inSelect = false;

  getBooks() {
    bookService.getBooks().then((value) {
//      print(value);
      setState(() {
        books = value;
      });
    });
  }

  void handleSearch() {
    Navigator
        .of(context)
        .push(new CustomPageRoute<Null>(builder: (BuildContext context) {
      return new Search(
        key: new Key(SearchType.local.toString()),
        searchType: SearchType.local,
      );
    }));
  }

  /// 点击跳转相应书籍
  void handleOnTap(Book book) {
    if (inSelect) {
      setState(() {
        if (selectedBooks.indexOf(book) >= 0) {
          selectedBooks.remove(book);
        } else {
          selectedBooks.add(book);
        }
      });
    } else {
      Navigator.push(
          context,
          new CustomPageRoute(
              builder: (context) => new Reader(
                    book: book,
                    prefs: widget.prefs,
                  )));
    }
  }

  /// 进入编辑模式
  void handleInEdit([Book book]) {
    print('handleInEdit book=$book');
    if (null == selectedBooks) {
      selectedBooks = new SelectedListModel<Book>(
          handleRemove: handleRemove, handleIndexOf: handleIndexOf);
    }
    if (inSelect) {
      if (null != book) {
        selectedBooks.add(book);
      }
    } else {
      inSelect = true;
      selectedBooks.add(book);
      // 隐藏底部导航栏
      widget.hideBottom(true);
    }
    setState(() {});
  }

  /// 退出编辑模式
  void handleOutEdit() {
    setState(() {
      inSelect = false;
      selectedBooks.clear();
    });
    // 显示底部导航栏
    widget.hideBottom(false);
  }

  ///SelectedListModel所用移除元素方法
  void handleRemove(Book book, List<Book> list) {
    if (list.length == 0) return;
    list.removeWhere((Book tmp) {
      return tmp == book;
    });
  }

  ///SelectedListModel所用查询索引方法
  int handleIndexOf(Book book, List<Book> list) {
    if (list.length == 0) return -1;
    return list.indexWhere((Book tmp) {
      return tmp == book;
    });
  }

  /// 全选
  void handleSelectAll() {
    if (selectedBooks.length >= books.length) {
      setState(() {
        selectedBooks.clear();
      });
    } else {
      setState(() {
        selectedBooks.clear();
        selectedBooks.addAll(books);
      });
    }
  }

  /// 从数据库删除选中书籍
  handleDelete() {
    print('handleDelete');
    if (!(selectedBooks.list.length > 0)) {
      return;
    }
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);
    showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              content: new Text('确定要删除吗？', style: dialogTextStyle),
              actions: <Widget>[
                new FlatButton(
                    child: new Text(
                      '取消',
                      style: new TextStyle(color: Colors.black87),
                    ),
                    onPressed: () {
                      Navigator.pop(context, false);
                    }),
                new FlatButton(
                    child: const Text('确定'),
                    onPressed: () {
                      Navigator.pop(context, true);
                    })
              ]);
        }).then((bool value) async {
      if (value) {
        print('执行删除');
        int count = await bookService.deleteBooks(selectedBooks.list);
        print('删除 $count 本书');
        setState(() {
          selectedBooks.clear();
          inSelect = false;
        });
        getBooks();
        if (null != count && count > 0) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                new Timer(
                    const Duration(seconds: 2), () => Navigator.pop(context));
                return new AlertDialog(
                  content: new Text('成功删除$count个资源'),
                );
              });
        } else if (null != count) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                new Timer(
                    const Duration(seconds: 1), () => Navigator.pop(context));
                return new AlertDialog(
                  content: new Text('删除失败'),
                );
              });
        }
      } else {
        print('取消');
      }
    });
  }

  void handleAction(Actions action) {
    switch (action) {
      case Actions.import:
        Navigator
            .of(context)
            .push(new CustomPageRoute(
                builder: (BuildContext context) => new ImportBook(
                      key: new Key('start'),
                      prefs: widget.prefs,
                      isRoot: true,
//                      path: '/storage/emulated/0/DuoKan/Downloads/MiCloudBooks',
//                  path: '/storage/emulated/0/DuoKan',
                    )))
            .then((_) {
          getBooks();
        });
        break;
      case Actions.changeTheme:
        print('widget.useLightTheme: ${widget.useLightTheme}');
        widget.onThemeChanged(!widget.useLightTheme);
        break;
      case Actions.edit:
        handleInEdit();
        break;
    }
  }

  Widget buildAppBar(BuildContext context) {
    return inSelect
        ? new AppBar(
            leading: new Container(
              width: 48.0,
              child: new FlatButton(
                onPressed: handleOutEdit,
                child: new Text(
                  '取消',
                  style: Theme.of(context).primaryTextTheme.button,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            title: new Text(selectedBooks.length > 0
                ? '已选择${selectedBooks.length}本图书'
                : '请选择图书'),
            brightness: Brightness.light,
            actions: <Widget>[
              new Container(
                width: 52.0,
                child: new FlatButton(
                  onPressed: handleSelectAll,
                  child: new Text(
                    selectedBooks.length >= books.length ? '全不选' : '全选',
                    style: Theme.of(context).primaryTextTheme.button,
                  ),
                  padding: EdgeInsets.zero,
                ),
              )
            ],
            centerTitle: true,
          )
        : new AppBar(
            title: new Text('收藏'),
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.search), onPressed: handleSearch),
              new PopupMenuButton<Actions>(
                onSelected: handleAction,
                itemBuilder: (BuildContext context) => <PopupMenuItem<Actions>>[
                      new PopupMenuItem(
                          child: new Text('编辑'), value: Actions.edit),
                      new PopupMenuItem(
                          child: new Text('导入'), value: Actions.import),
                      new PopupMenuItem(
                          child:
                              new Text(widget.useLightTheme ? '夜间模式' : '白天模式'),
                          value: Actions.changeTheme),
                    ],
              )
            ],
          );
  }

  ///构建选择模式底部组件
  Widget buildBottomBar() {
    return new Container(
        height: 48.0,
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Expanded(
                child: new FlatButton(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    onPressed: handleDelete,
                    child: new Text('删除')),
              ),
            ]));
  }

  Widget buildBody(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new Offstage(
          offstage: books.isNotEmpty,
          child: new Center(
            child: new Text('空空如也!'),
          ),
        ),
        new Offstage(
          offstage: books.isEmpty,
          child: new Column(
            children: <Widget>[
              new Expanded(
                child: new GridView.extent(
                  maxCrossAxisExtent: 130.0,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 24.0,
                  padding: const EdgeInsets.all(24.0),
                  childAspectRatio: 0.46,
                  children: books
                      .map((Book book) => new BookItem(
                            book: book,
                            inSelect: inSelect,
                            selectedBooks: selectedBooks,
                            showReadProgress: widget.showReadProgress,
                            onTap: handleOnTap,
                            onLongPress: handleInEdit,
                          ))
                      .toList(),
                ),
              ),
              new Offstage(
                offstage: !inSelect,
                child: new Column(children: <Widget>[
                  new Divider(height: 1.0),
                  buildBottomBar()
                ]),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getBooks();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(appBar: buildAppBar(context), body: buildBody(context));
  }
}
