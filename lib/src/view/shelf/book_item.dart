import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/model/selected_list_model.dart';

class BookItem extends StatelessWidget {
  BookItem(
      {@required this.book,
      @required this.showReadProgress,
      @required this.onTap,
      @required this.onLongPress,
      @required this.inSelect,
      @required this.selectedBooks});

  final ValueChanged<Book> onTap;
  final ValueChanged<Book> onLongPress;
  final Book book;
  final bool inSelect;
  final bool showReadProgress;
  final SelectedListModel<Book> selectedBooks;

  final RegExp regHttp = new RegExp(r'^http');

  ///检查是否选中
  bool checkSelected() {
    if (null != selectedBooks && selectedBooks.indexOf(book) >= 0) return true;
    return false;
  }

  ///295/405
  List<Widget> buildCover(BuildContext context) {
    Image image;
    if (null == book.coverUri || book.coverUri.isEmpty) {
      image = new Image.asset(
        'assets/default_cover.jpg',
        fit: BoxFit.cover,
      );
    } else if (regHttp.hasMatch(book.coverUri)) {
      image = new Image.network(
        book.coverUri,
        fit: BoxFit.cover,
      );
    } else {
      image = new Image.file(
        new File(book.coverUri),
        fit: BoxFit.cover,
      );
    }
    return <Widget>[
      new Positioned.fill(child: image),
//      new Positioned(
//        top: -5.0,
//        right: -5.0,
//        child: new Offstage(
//          offstage: !inSelect,
//          child: new SizedBox(
//            height: 21.0,
//            width: 21.0,
//            child: new CircleAvatar(
//              backgroundColor: Colors.white,
//            ),
//          ),
//        ),
//      ),
      new Positioned(
        top: -5.0,
        right: -5.0,
        child: new Offstage(
          offstage: true,
          child: new SizedBox(
            height: 21.0,
            width: 21.0,
            child: new CircleAvatar(
              backgroundColor: Colors.red,
              child: new Text(
                '2',
                style: new TextStyle(fontSize: 12.0),
              ),
            ),
          ),
        ),
      ),
//      new Offstage(
//        offstage: ,
//      )
    ]..addAll(<Widget>[
        new Positioned(
          top: -5.0,
          right: -5.0,
          child: new Offstage(
            offstage: !inSelect,
            child: new SizedBox(
              height: 21.0,
              width: 21.0,
              child: new Container(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 1.0),
                decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: new Border.all(color: Colors.red, width: 1.0)),
              ),
            ),
          ),
        ),
        new Positioned(
          top: -7.0,
          right: -4.0,
          child: new Offstage(
            offstage: !inSelect || !checkSelected(),
            child: new SizedBox(
              height: 21.0,
              width: 21.0,
              child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: new Icon(
                  Icons.check_circle,
                  color: Colors.red,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ),
      ]);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () => onTap(book),
      onLongPress: () => onLongPress(book),
      child: new Container(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Flexible(
              child: new Stack(
                children: buildCover(context),
                overflow: Overflow.visible,
              ),
            ),
            new Container(
              height: showReadProgress ? 68.0 : 48.0,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    child: new Text(
                      book.title,
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  new Offstage(
                      offstage: !showReadProgress,
                      child: new Text(
                        '已阅读3%',
                        style: Theme
                            .of(context)
                            .textTheme
                            .body2
                            .copyWith(color: Colors.grey),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
