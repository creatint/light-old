import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:light/src/view/explore/explore.dart';
import 'package:light/src/view/shelf/shelf.dart';
import 'package:light/src/view/profile/profile.dart';

class Home extends StatefulWidget {
  const Home(
      {Key key,
      @required this.useLightTheme,
      @required this.prefs,
      @required this.onThemeChanged})
      : assert(useLightTheme != null),
        assert(onThemeChanged != null),
        super(key: key);

  final bool useLightTheme;
  final SharedPreferences prefs;
  final ValueChanged<bool> onThemeChanged;

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  List<_NavigationItem> navigationItems; //导航元素
  int currentIndex = 1; //当前导航索引
  List<Widget> pages = <Widget>[]; //页面列表

  Widget _buildNavigations(BuildContext context) {
    if (navigationItems == null || navigationItems.length == 0) {
      navigationItems = <_NavigationItem>[
        new _NavigationItem(
            icon: Icons.explore,
            prefs: widget.prefs,
            title: '发现',
            name: _NavigationName.explore,
            useLightTheme: widget.useLightTheme,
            onThemeChanged: widget.onThemeChanged),
        new _NavigationItem(
            icon: Icons.import_contacts,
            prefs: widget.prefs,
            title: '收藏',
            name: _NavigationName.shelf,
            useLightTheme: widget.useLightTheme,
            onThemeChanged: widget.onThemeChanged),
        new _NavigationItem(
            icon: Icons.explore,
            prefs: widget.prefs,
            title: '我的',
            name: _NavigationName.profile,
            useLightTheme: widget.useLightTheme,
            onThemeChanged: widget.onThemeChanged),
      ];
    }
    return new BottomNavigationBar(
      items: navigationItems.map((_NavigationItem navItem) {
        return navItem.item;
      }).toList(),
      onTap: (int index) {
        setState(() {
          currentIndex = index;
        });
      },
      currentIndex: currentIndex,
    );
  }

  Widget _buildPage(BuildContext context, int index) {
    navigationItems[index].build(context);
    navigationItems.forEach((_NavigationItem item) {
      if (!(pages.indexOf(item.page) >= 0) && item.page != null) {
        pages.add(item.page);
      }
    });
    pages
      ..removeWhere((Widget page) => page == navigationItems[index].page)
      ..add(navigationItems[index].page);
    return new Stack(
      children: pages,
    );
  }

  Widget build(BuildContext context) {
    Widget bottomNavigationBar = _buildNavigations(context);
    return new Scaffold(
        body: _buildPage(context, currentIndex),
        bottomNavigationBar: bottomNavigationBar);
  }
}

enum _NavigationName { explore, shelf, profile }

class _NavigationItem {
  _NavigationItem(
      {@required IconData icon,
      @required this.title,
      @required this.name,
      @required this.useLightTheme,
      @required this.prefs,
      @required this.onThemeChanged})
      : this.item = new BottomNavigationBarItem(
            icon: new Icon(icon), title: new Text(title));
  final useLightTheme;
  final SharedPreferences prefs;
  final ValueChanged<bool> onThemeChanged;
  final String title;
  final _NavigationName name;
  final BottomNavigationBarItem item;
  Widget page;

  Widget build(BuildContext context) {
    if (page != null) {
      return page;
    }
    switch (name) {
      case _NavigationName.explore:
        page = new Explore(
          key: new Key(name.toString()),
          useLightTheme: useLightTheme,
          onThemeChanged: onThemeChanged,
        );
        break;
      case _NavigationName.shelf:
        page = new Shelf(
          key: new Key(name.toString()),
          useLightTheme: useLightTheme,
          prefs: prefs,
          onThemeChanged: onThemeChanged,
          showReadProgress: true,
        );
        break;
      case _NavigationName.profile:
        page = new Profile(
          key: new Key(name.toString()),
          useLightTheme: useLightTheme,
          onThemeChanged: onThemeChanged,
        );
        break;
      default:
      //error
    }
    return page;
  }
}
