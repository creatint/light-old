import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:light/src/model/book.dart';

class BookItem extends StatelessWidget {
  BookItem(
      {@required this.book,
      @required this.showReadProgress,
      @required this.onTap});

  final ValueChanged<Book> onTap;
  final Book book;
  final bool showReadProgress;

  final RegExp regHttp = new RegExp(r'^http');

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
      new Positioned(
        top: -5.0,
        right: -5.0,
        child: new Offstage(
          offstage: true,
          child: new SizedBox(
            height: 22.0,
            width: 22.0,
            child: new CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
      new Positioned(
        top: -5.0,
        right: -5.0,
        child: new Offstage(
          offstage: true,
          child: new SizedBox(
            height: 20.0,
            width: 20.0,
            child: new CircleAvatar(
              backgroundColor: Colors.red,
              child: new Text(
                '2',
                style: new TextStyle(fontSize: 12.0),
              ),
            ),
          ),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: (){
        onTap(book);
      },
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
