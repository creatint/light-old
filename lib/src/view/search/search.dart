import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:light/src/view/custom_page_route.dart';
import 'package:light/src/model/book.dart';
import 'package:light/src/view/search/tieba/search_tieba.dart';
import 'package:light/src/service/search.dart';
import 'package:light/src/view/custom_indicator.dart';
import 'package:light/src/view/search/search_item.dart';

///搜索类型 online:在线搜索 local:本地搜索
enum SearchType { online, local }

class Search extends StatefulWidget {
  Search(
      {@required Key key,
      @required this.searchType: SearchType.online,
      this.isSearched: false,
      this.word: null})
      : super(key: key);

  final SearchType searchType;
  final bool isSearched; //搜索过的页面搜索时不再跳转路由
  String word; //word不为null，则为结果页面

  @override
  SearchState createState() =>
      new SearchState(isSearched: isSearched, word: word);
}

class SearchState extends State<Search> with SingleTickerProviderStateMixin {
  SearchState({this.isSearched, this.word});

  final TextEditingController textEditingController =
      new TextEditingController(); //输入框控件
  bool isSearched; //避免初始化时显示seggestions，初始化后置为false
  String word; //用于搜索的关键字
  bool isLoadding = false;
  List<String> suggestions = <String>[]; //搜索建议
  List<String> histories = <String>[]; //搜索历史
  List<Book> recommends = <Book>[]; //资源推荐
  List<Book> results = null; //搜索结果
  AnimationController controller;
  Animation<double> animation;
  Widget defaultCover = new CircleAvatar(
    child: new Text('书'),
  );

  ///执行搜索，获取结果
  void doSearch(String text) {
    print('doSearch text=$text');
    setState(() {
      isLoadding = true;
      word = text;
      textEditingController.text = text;
    });
    print('widget.word=${widget.word}');
    getOnlineBooksAll(text).then((res) {
      print('获取数据');
      print(res);
      setState(() {
        isLoadding = false;
        suggestions.clear();
        results = res;
      });
    });
  }

  ///处理搜索事件
  void handleSearch(BuildContext context, String text) {
    print('handleSearch text=$text');
    if (text.isEmpty) {
      return;
    }
    print('handleSearch isSearch=${widget.isSearched.toString()}');
    if (widget.isSearched) {
      print('不跳转路由');
      //处于结果路由，不再跳转路由
      doSearch(text);
    } else {
      //处于开始页面，跳转路由
      print('跳转路由');
      textEditingController?.clear();
      suggestions?.clear();
      Navigator
          .of(context)
          .push(new CustomPageRoute(builder: (BuildContext context) {
        return new Search(
            key: new Key(widget.searchType.toString() + text),
            searchType: widget.searchType,
            isSearched: true,
            word: text);
      }));
    }
  }

  void _searchTieba(BuildContext context) {
    print('_searchTieba');
    Navigator
        .of(context)
        .push(new CustomPageRoute(builder: (BuildContext context) {
      return new SearchTieba(
        word: textEditingController.text,
      );
    }));
  }

  ///处理输入框中字符改变事件
  void handleChanged(String text) {
    print('handleChanged text=$text text.isEmpty=${text.isEmpty}');
    if (isSearched) {
      isSearched = false;
      return;
    }
    setState(() {
      isLoadding = true;
      suggestions.clear();
    });
    if (text.isEmpty) {
      return;
    }
    if (widget.searchType == SearchType.online) {
      ///在线查询
      String url = 'https://sp0.baidu.com/'
          '5a1Fazu8AA54nxGko9WTAnF6hhy/su?wd=%WORD%&json=1&csor=0&ie=utf-8'
          .replaceFirst(new RegExp('%WORD%'), text);
      RegExp reg = new RegExp(r'window\.baidu\.sug\((.*)\);');

      http.get(url).then((var response) {
        Match matche = reg.firstMatch(response.body);
        if (matche != null) {
          String str = matche.group(1);
          var res = JSON.decode(str);
          if (res['s'] != null) {
            if (textEditingController.text.isNotEmpty) {
              print('handleChanged2 text=$text isEmpty=${text.isEmpty}');
              setState(() {
                suggestions = res['s'];
                isLoadding = false;
              });
            }
            return;
          }
        }
        throw '查询失败，无法联网或API不可用';
      }).catchError((var error) {
        print('出错啦！！$error');
      });
    } else if (widget.searchType == SearchType.local) {
      ///本地查询

    }
  }

  ///构建搜索框
  Widget buildSearchField(BuildContext context) {
    return new TextField(
      style: new TextStyle(color: Colors.white, fontSize: 18.0),
      autofocus: !widget.isSearched,
      controller: textEditingController,
      onChanged: handleChanged,
      onSubmitted: (String text) {
        handleSearch(context, text);
      },
      decoration: new InputDecoration(
        border: InputBorder.none,
        hintText: widget.isSearched ? word : '作品、作者',
        hintStyle: new TextStyle(color: Colors.white30, fontSize: 18.0),
        suffixIcon: new Offstage(
          offstage: textEditingController.text == null ||
              textEditingController.text.isEmpty,
          child: new IconButton(
              icon: new Icon(
                Icons.clear,
                color: Colors.white70,
              ),
              onPressed: () {
                //重置列表
                setState(() {
                  word = null;
                  textEditingController.clear();
                  suggestions.clear();
                });
              }),
        ),
      ),
    );
  }

  ///构建AppBar
  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: buildSearchField(context),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.search),
          onPressed: () {
            handleSearch(context, textEditingController.text);
          },
        ),
      ],
    );
  }

  ///构建初始页，输入框为空时显示，包括搜索历史、推荐资源等
  Widget buildStart(BuildContext context) {
    return new Offstage(
      offstage: (null != suggestions && suggestions.isNotEmpty) ||
          textEditingController.text.isNotEmpty,
      child: new Center(
        child: new Text('无历史'),
      ),
    );
  }

  ///构建搜索建议，输入框中有文字时获取搜索建议
  Widget buildSuggestions(BuildContext context) {
    List<Widget> items = <Widget>[];
    if (suggestions == null || suggestions.isEmpty) {
      return new Offstage(
          offstage: null == suggestions || suggestions.isEmpty,
          child: new Container());
    }
    items.add(new ListTile(
      leading: new Icon(Icons.search),
      title: new Text('搜索贴吧？'),
      onTap: () {
        _searchTieba(context);
      },
    ));
    for (String title in suggestions) {
      if (title.isNotEmpty) {
        items.add(new SearchItem(
          title: title,
          style: new TextStyle(color: Colors.black26),
          onTap: () {
            handleSearch(context, title);
          },
        ));
      }
    }
    return new Offstage(
      offstage: null == suggestions || suggestions.isEmpty,
      child: new Container(
//      color: Colors.white,
//    color: Theme.of(context).backgroundColor,
        child: new ListView(
          children: ListTile
              .divideTiles(
                context: context,
                tiles: items,
              )
              .toList(),
        ),
      ),
    );
  }

  Widget buildCover(BuildContext context, Book book) {
    RegExp reg = new RegExp('^http');
    if (null == book.coverUri || book.coverUri.isEmpty) {
      return defaultCover;
    }
    if (reg.hasMatch(book.coverUri)) {
      return new Image.network(book.coverUri);
    }
    return new Image.file(new File(book.coverUri));
  }

  ///构建搜索结果
  Widget buildResults(BuildContext context) {
    print('buildResults');
    List<Widget> items = <Widget>[];
    if (results == null || results.isEmpty) {
      items.add(new Container(
        alignment: Alignment.center,
        height: 50.0,
        child: new Text(
          '无结果',
          textAlign: TextAlign.center,
        ),
      ));
      items.add(new ListTile(
        leading: new Icon(Icons.search),
        title: new Text('搜索贴吧？'),
        onTap: () {
          _searchTieba(context);
        },
      ));
    } else {
      for (Book book in results) {
        if (book != null) {
          items.add(new SearchItem(
            cover: buildCover(context, book),
            title: book.title,
            subtitle: book.description,
            style: new TextStyle(color: Colors.black26),
          ));
        }
      }
    }
    return new Offstage(
      offstage: !widget.isSearched || textEditingController.text.isEmpty,
      child: new Container(
//      color: Colors.white,
        child: new ListView(
          children: ListTile
              .divideTiles(
                context: context,
                tiles: items,
              )
              .toList(),
        ),
      ),
    );
  }

  Widget buildIndicator(BuildContext context) {
    return new Offstage(offstage: !isLoadding, child: new CustomIndicator());
  }

  ///构建页面
  Widget buildBody(BuildContext context) {
    print('buildBody text=${textEditingController
        .text} suggestion.isEmpty=${suggestions.isEmpty}');
    List<Widget> pages = <Widget>[];
    //初始页面
    pages.add(buildStart(context));

    ///有结果则显示结果
    pages.add(buildResults(context));

    ///有搜索建议则显示搜索建议
    pages.add(buildSuggestions(context));

    ///是否显示加载动画
    pages.add(buildIndicator(context));
    return new Stack(children: pages);
  }

  @override
  void initState() {
    super.initState();
    print('initState');
    if (widget.word != null && widget.word.isNotEmpty) {
      //存在word，进行搜索
      textEditingController.text = widget.word;
      doSearch(widget.word);
    }
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose');
    suggestions?.clear();
    results?.clear();
    textEditingController?.clear();
    textEditingController?.dispose();
    controller?.stop();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(appBar: buildAppBar(context), body: buildBody(context));
  }
}
