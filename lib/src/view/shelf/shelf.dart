//import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:light/src/service/book_service.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/view/search/search.dart';
import 'package:light/src/view/custom_page_route.dart';
import 'package:light/src/view/shelf/import_book.dart';
import 'package:light/src/view/shelf/book_item.dart';
import 'package:light/src/view/reader/reader.dart';

class Shelf extends StatefulWidget {
  Shelf(
      {@required Key key,
      @required this.useLightTheme,
      @required this.prefs,
      @required this.onThemeChanged,
      @required this.showReadProgress})
      : super(key: key);
  final bool useLightTheme;
  final SharedPreferences prefs;
  final bool showReadProgress;
  final ValueChanged<bool> onThemeChanged;

  @override
  _ShelfState createState() => new _ShelfState();
}

enum Actions { import, changeTheme }

class _ShelfState extends State<Shelf> {
  List<Book> books = <Book>[];
  BookService bookService = new BookService();

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

  void handleOnTap(Book book) {
    Navigator.push(
        context,
        new CustomPageRoute(
            builder: (context) => new Reader(
                  book: book,
                  prefs: widget.prefs,
                )));
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
    }
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Text('收藏'),
      actions: <Widget>[
        new IconButton(icon: new Icon(Icons.search), onPressed: handleSearch),
        new PopupMenuButton<Actions>(
          onSelected: handleAction,
          itemBuilder: (BuildContext context) => <PopupMenuItem<Actions>>[
                new PopupMenuItem(child: new Text('导入'), value: Actions.import),
                new PopupMenuItem(
                    child: new Text(widget.useLightTheme ? '夜间模式' : '白天模式'),
                    value: Actions.changeTheme),
              ],
        )
      ],
    );
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
          child: new GridView.extent(
            maxCrossAxisExtent: 130.0,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 24.0,
            padding: const EdgeInsets.all(24.0),
            childAspectRatio: 0.46,
            children: books
                .map((Book book) => new BookItem(
                      book: book,
                      showReadProgress: widget.showReadProgress,
                      onTap: handleOnTap,
                    ))
                .toList(),
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
