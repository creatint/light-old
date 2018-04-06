import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:light/src/view/custom_page_route.dart';
import 'package:light/src/view/search/search.dart';
import 'package:light/src/service/db.dart';

class Explore extends StatefulWidget {
  Explore(
      {@required Key key,
      @required this.useLightTheme,
      @required this.onThemeChanged})
      : super(key: key);
  final bool useLightTheme;
  final ValueChanged<bool> onThemeChanged;

  @override
  _ExploreState createState() => new _ExploreState();
}

class _ExploreState extends State<Explore> {
  @override
  void initState() {
    super.initState();
    print('init Explore state...');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('Light'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                  new CustomPageRoute<Null>(builder: (BuildContext context) {
                return new Search(
                  key: new Key(SearchType.online.toString()),
                  searchType: SearchType.online,
                );
              }));
            },
          )
        ],
      ),
      body: new Center(
        child: new Text('Explore'),
      ),
    );
  }
}
