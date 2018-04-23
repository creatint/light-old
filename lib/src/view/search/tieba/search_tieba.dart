import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

import 'package:light/src/widgets/custom_page_route.dart';
import 'package:light/src/view/search/search_item.dart';
import 'package:light/src/widgets/custom_indicator.dart';
import 'package:light/src/view/search/tieba/tieba.dart';

class SearchTieba extends StatefulWidget {
  SearchTieba({
    this.word
  });
  final String word;
  @override
  SearchTiebaState createState() => new SearchTiebaState(word: word);
}

class SearchTiebaState extends State<SearchTieba> {
  SearchTiebaState({
    this.word
  });
  String word;
  TextEditingController textEditingController = new TextEditingController();
  List<String> suggestions = <String>[];
  List<Map> results = <Map>[];
  bool isLoadding = false;

  ///跳转到贴吧
  void jump(BuildContext context, Map tieba) {
    print('tap on tieba=${tieba['fname']}');
    Navigator.of(context).push(new CustomPageRoute(builder:
        (BuildContext context) => new Tieba(fname: tieba['fname'])
    ));
  }

  ///执行搜索
  void handleSearch(String text) {
    print('handleSearch word=$text');
    if (text == null || text.isEmpty) {
      return null;
    }
    setState((){
      word = text;
      isLoadding = true;
      suggestions?.clear();
      results?.clear();
    });
    //获取results
    int time = new DateTime.now().millisecondsSinceEpoch;
    print('time=$time');
    String url = 'http://tieba.baidu.com/suggestion?query=%WORD%&ie=utf-8&_=%TIME%'
        .replaceFirst(new RegExp(r'%WORD%'), text)
        .replaceFirst(new RegExp(r'%TIME%'), time.toString());
    print(url);
    get(url).then((response){
      Map res = json.decode(response.body);
      print(res);
      if (res == null && res.isEmpty) {
        return;
      }else if (res['error'] != 0 || res['query_match'] == null
          || res['query_match']['search_data'] == null) {
        //TODO:贴吧API ERROR，记录日志
        return;
      }
      res['query_match']['search_data'].forEach((tieba){
        print(tieba);
        setState((){
          results.add(tieba);
        });
      });
      setState((){
        isLoadding = false;
      });
    });

  }

  ///处理搜索框文字改变事件
  void handleChanged(String text) {
    print('handleChanged text=$text');
    setState((){
      suggestions.clear();
    });
    if (text == null || text.isEmpty) {
      return;
    }
    //获取suggestion
    int time = new DateTime.now().millisecondsSinceEpoch;
    print('time=$time');
    String url = 'http://tieba.baidu.com/suggestion?query=%WORD%&ie=utf-8&_=%TIME%'
        .replaceFirst(new RegExp(r'%WORD%'), text)
        .replaceFirst(new RegExp(r'%TIME%'), time.toString());
    print(url);
    get(url).then((response){
      Map result = json.decode(response.body);
      print(result);
      if (result == null && result.isEmpty) {
        return;
      }else if (result['error'] != 0 || result['query_match'] == null
          || result['query_match']['search_data'] == null) {
        //TODO:贴吧API ERROR，记录日志
        return;
      }
      result['query_match']['search_data'].forEach((Map tieba){
        print(tieba);
        setState((){
          suggestions.add(tieba['fname']);
        });
      });
    });
//    new http.HttpClient();

  }


  ///构建搜索框
  Widget buildSearchField(BuildContext context) {
    return new TextField(
      onChanged: handleChanged,
      style: new TextStyle(
          color: Colors.white,
          fontSize: 18.0
      ),
      controller: textEditingController,
      decoration: new InputDecoration(
        hintText: word ?? '贴吧',
        border: InputBorder.none,
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
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: buildSearchField(context),
      actions: <Widget>[
        new IconButton(icon: new Icon(Icons.search), onPressed: (){
          handleSearch(textEditingController.text);
        })
      ],
    );
  }

  ///构建suggestions
  Widget buildSuggestions(BuildContext context) {
    List<Widget> items = <Widget>[];
    if (suggestions == null || suggestions.isEmpty) {
      return null;
    }
    for(String title in suggestions) {
      if (title.isNotEmpty) {
        items.add(new SearchItem(
          title: title,
          style: new TextStyle(color: Colors.black26),
          onTap: (){
            handleSearch(title);
          },
        ));
      }
    }
    return new Container(
      color: Colors.white,
      child: new ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: items,
        ).toList(),
      ),
    );
  }

  ///构建results
  Widget buildResults(BuildContext context) {
    List<Widget> items = <Widget>[];
    if (results == null || results.isEmpty) {
      return null;
    }
    results.forEach((Map tieba){
      if (tieba != null && tieba.isNotEmpty) {
        items.add(new ListTile(
          leading: new Image.network(tieba['fpic']),
          title: new Text(tieba['fname'] + '吧'),
          onTap: (){
            jump(context, tieba);
          },
        ));
      }
    });
    return new Container(
      child: new ListView(
        children: ListTile.divideTiles(
            context: context,
            tiles: items
        ).toList(),
      ),
    );
  }

  ///构建加载动画页面
  Widget buildIndicator(BuildContext context) {
    return new CustomIndicator();
  }

  ///构建页面
  Widget buildBody(BuildContext context) {
    List<Widget> pages = <Widget>[];
    if (results != null && results.isNotEmpty) {
      pages.add(buildResults(context));
    }
    if (suggestions != null && suggestions.isNotEmpty) {
      pages.add(buildSuggestions(context));
    }
    if (isLoadding) {
      pages.add(buildIndicator(context));
    }
    return new Stack(children: pages,);
  }

  ///初始化
  @override
  void initState() {
    super.initState();
    print('tieba init word=${widget.word}');
    if (word != null && word.isNotEmpty) {
      //存在word，进行搜索
      textEditingController.text = word;
      handleSearch(word);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }
}