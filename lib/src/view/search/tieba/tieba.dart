import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
//import 'package:sqflite/sqflite.dart';

import 'package:light/src/widgets/custom_page_route.dart';
import 'package:light/src/model/tieba_topic.dart';
import 'package:light/src/view/search/tieba/detail.dart';
import 'package:light/src/widgets/custom_indicator.dart';
//import 'package:light/src/parts/select_bottom_bar.dart';

class Tieba extends StatefulWidget {
  Tieba({@required this.fname, this.hasCollected});

  final String fname;
  final bool hasCollected;

  @override
  TiebaState createState() => new TiebaState();
}

enum Action { refresh, collection, select }

class TiebaState extends State<Tieba> {
  final Key listKey = new Key('list'); //无限列表的key
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool isLoading = true; //是否显示加载动画页面
  bool isLoadingMore = false; //“更多”是否加载中
  bool showSearch = false; //是否显示搜索栏
  bool hasCollected = false; //当前贴吧是否收藏
  bool inSelect = false; //是否处于选择模式
  bool noNetwordk = false;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController scrollController = new ScrollController();
  final ScrollPhysics scrollPhysics = new BouncingScrollPhysics();
  List<String> history = <String>[]; //搜索规则历史
  String baseUrl = 'http://tieba.baidu.com/mo/m?kw=%KW%&pn=%PN%';
  String tiebaUrl = 'http://tieba.baidu.com'; //用于拼接的链接
  String nextUrl; //下一页链接
  int currPageNumber = 0; //当前页面-1
  final RegExp regKW = new RegExp(r'%KW%');
  final RegExp regPN = new RegExp(r'%PN%');
  final RegExp regReplaceUrl = new RegExp(r'(m\?k.+)$');
  final RegExp regGetUrlPiece = new RegExp(r'^(.*)(m\?k.+)$');
  final RegExp regGetId = new RegExp(r'kz=(\d+)');
  final RegExp regClickTimes = new RegExp(r'点([0-9]+)');
  final RegExp regReplyTimes = new RegExp(r'回([0-9]+)');
  RegExp regSearch; //用于筛选的字符串
  List<TiebaTopic> topics = <TiebaTopic>[]; //主题列表
  final SelectedListModel selectedTopics = new SelectedListModel(); //已选中的主题列表

  ///内容过滤,无reg则直接返回true
  bool filter(String text) {
    if (regSearch == null) {
      return true;
    }
    print(text);
    print(regSearch.pattern);
    print(regSearch.hasMatch(text));
    return regSearch.hasMatch(text);
  }

  ///处理搜索事件，重置页码
  void doSearch(String text) {
    print('doSearch text=$text');
    text = text.replaceAll(r' ', '.*');
    setState(() {
      regSearch = new RegExp(text);
      showSearch = false;
      isLoading = true;
      topics.clear();
    });
    requestTiebaTopics(callback: () {
      setState(() {
        isLoading = false;
      });
    });
  }

  ///展开搜索框
  void handleSearchBar() {
    print('handleSearchBar');
    if (showSearch) {
      setState(() {
        showSearch = false;
      });
    } else {
      setState(() {
        showSearch = true;
      });
    }
  }

  Future<Null> handleRefresh() async {
    setState(() {
      topics.clear();
      isLoading = true;
    });
    return requestTiebaTopics(callback: () {
      setState(() {
        isLoading = false;
      });
    });
  }

  ///弹窗按钮事件
  void handleAction(Action action) {
    print('action = $action');
    switch (action) {
      case Action.refresh:
        handleRefresh();
        break;
      case Action.collection:
        setState(() {
          hasCollected = !hasCollected;
        });
        break;
      case Action.select:
        if (!inSelect) {
          setState(() {
            inSelect = true;
          });
        } else {
          setState(() {
            selectedTopics.clear();
            inSelect = false;
          });
        }
    }
  }

  ///删除历史记录事件
  void handleDeleteHistory() {
    print('handleDeleteHistory');
  }

  ///处理点击事件
  void handleTap(BuildContext context, TiebaTopic topic) {
    print('handleTap ${topic.title}');
    if (inSelect) {
      setState(() {
        if (selectedTopics.indexOf(topic) >= 0) {
          selectedTopics.remove(topic);
        } else {
          selectedTopics.add(topic);
        }
      });
    } else {
      print(topic.url);
      Navigator.of(context).push(new CustomPageRoute(
          builder: (BuildContext context) => new Detail(topic: topic)));
    }
  }

  ///处理长按事件
  void handleLongPress(TiebaTopic topic) {
    print('handleLongPress');
    print(topic);
    if (!inSelect) {
      setState(() {
        selectedTopics.add(topic);
        inSelect = true;
      });
    }
  }

  ///全选事件
  void handleSelectAll() {
    if (selectedTopics.length >= topics.length) {
      setState(() {
        selectedTopics.clear();
      });
    } else {
      selectedTopics.clear();
      setState(() {
        selectedTopics.addAll(topics);
      });
    }
  }

  void handleCreateBook() {
    print('handleCreateBook');
  }

  ///处理页码
  void handlePageNumber() {}

  ///处理加载更多事件
  void handleLoadMore() {
    print('handleLoadMore');
    setState(() {
      isLoadingMore = true;
    });
    requestTiebaTopics(
        url: nextUrl,
        callback: () {
          setState(() {
            isLoadingMore = false;
          });
        });
  }

  int getTopicId(String url) {
    return int.parse(regGetId.firstMatch(url)?.group(1));
  }

  String getFullUrl(String part, String base) {
    return base.replaceFirst(
        regReplaceUrl, regGetUrlPiece.firstMatch(part)?.group(2));
  }

  ///获取帖子列表数据
  Future<Null> requestTiebaTopics(
      {String url, int pageNumber, VoidCallback callback}) async {
    if (url == null) {
      url = baseUrl.replaceAll(regKW, widget.fname).replaceAll(
          regPN, pageNumber?.toString() ?? currPageNumber.toString());
    }
    print('requestTiebaTopics url = $url');
    if (topics == null) {
      topics = <TiebaTopic>[];
    }
    try {
      return get(url).then((response) {
        print('request.url = ' + response.request.url.toString());
        dom.Document document = parser.parse(response.body);
        List<dom.Element> topicElements =
            document.body.querySelectorAll('div.i');
        if (topicElements == null || topicElements.length == 0) {
          //TODO:无帖子
          print('无帖子');
          return;
        }

        topicElements.forEach((topic) {
          dom.Element a = topic.querySelector('a');
          if (a == null) {
            //TODO:无链接
          }
          String title = a.innerHtml
              .replaceAll(new RegExp(r'&nbsp;'), ' ')
              .replaceAll(new RegExp(r'\s+'), ' ')
              .replaceFirst(new RegExp(r'^\d\d?\.'), '')
              .trim();
          //搜索时过滤
          if (!filter(title)) {
            print('移除 $title');
            return;
          }
//          print('tiebaUrl= ${tiebaUrl}');
//          print('hrefUrl = ${a.attributes['href']}');
//          String url = tiebaUrl + a.attributes['href'];
          String url =
              getFullUrl(a.attributes['href'], response.request.url.toString());
          int id = getTopicId(url);

          String subinfo = topic.querySelector('p').innerHtml;
          int clickTimes =
              int.parse(regClickTimes.firstMatch(subinfo)?.group(1));
          int replyTimes =
              int.parse(regReplyTimes.firstMatch(subinfo)?.group(1));
//        print('title=$title\nurl=$url');
          if (title != null && url != null) {
            setState(() {
              topics.add(new TiebaTopic(
                  title: title,
                  id: id,
                  url: url,
                  tiebaUrl: tiebaUrl,
                  clickTimes: clickTimes,
                  replyTimes: replyTimes));
            });
          }
        });

        //获取下一页链接
        dom.Element next = document.body.querySelector('div.bc.p>a');
        if (next != null &&
            next.innerHtml == '下一页' &&
            next.attributes['href'] != null) {
          nextUrl = getFullUrl(
              next.attributes['href'], response.request.url.toString());
          print('nextUrl = $nextUrl');
//          if (nextUrl == null) {
//            tiebaUrl +=
//                regGetUrlPiece.firstMatch(next.attributes['href'])?.group(1);
//          }
//          nextUrl = tiebaUrl + next.attributes['href'];
        } else {
          nextUrl = null;
        }
      }).whenComplete(() {
        if (callback != null) {
          return callback();
        }
      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } catch (e) {
      print('Error: $e');
    }
  }

  ///监听滚动事件
  void handleScroll(ScrollPosition position) {
    if (!isLoadingMore && (position.pixels - position.maxScrollExtent) > 80) {
      handleLoadMore();
    }
  }

  ///构建AppBar
  Widget buildAppBar(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Widget> actions = <Widget>[];
    actions.add(
      new IconButton(icon: new Icon(Icons.search), onPressed: handleSearchBar),
    );
    actions.add(new PopupMenuButton<Action>(
      onSelected: handleAction,
      itemBuilder: (BuildContext context) => <PopupMenuItem<Action>>[
            new PopupMenuItem(
              value: Action.refresh,
              child: new Text('刷新'),
            ),
            new PopupMenuItem(
              value: Action.collection,
              child: new Text(hasCollected ? '取消收藏' : '收藏贴吧'),
            ),
            new PopupMenuItem(
              value: Action.select,
              child: new Text(inSelect ? '取消创建' : '创建资源'),
            ),
          ],
    ));
    Widget bottom = showSearch
        ? new PreferredSize(
            preferredSize: new Size(30.0, 48.0),
            child: new Container(
              padding: const EdgeInsets.only(left: 16.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Container(
                      padding: const EdgeInsets.only(left: 5.0),
                      decoration: new BoxDecoration(
                          color: Colors.white30,
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(5.0))),
                      child: new TextField(
                        style: theme.accentTextTheme.body1,
                        maxLines: 1,
                        autofocus: showSearch,
                        keyboardType: TextInputType.text,
                        onSubmitted: doSearch,
                        controller: textEditingController,
                        decoration: new InputDecoration(
                          hintText: '关键字、正则',
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4.0),
                          border: InputBorder.none,
                          suffixIcon: new IconButton(
                              icon: new Icon(
                                Icons.clear,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                //重置列表
                                setState(() {
                                  textEditingController.clear();
                                  regSearch = null;
                                });
                                requestTiebaTopics();
                              }),
                        ),
                      ),
                    ),
                  ),
                  new IconButton(
                      icon: new Icon(
                        Icons.send,
                        color: theme.buttonColor,
                      ),
                      onPressed: () {
                        doSearch(textEditingController.text);
                      })
                ],
              ),
            ))
        : null;
    return new AppBar(
      title: new Text(
        '${widget.fname}吧',
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return new Container(
      height: 48.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Container(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: new Text('已选${selectedTopics.length}项')),
              new FlatButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  onPressed: handleSelectAll,
                  child: new Text(
                    selectedTopics.length >= topics.length ? '全不选' : '全选',
                  )),
              new FlatButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  onPressed: () {
                    setState(() {
                      selectedTopics.clear();
                      inSelect = false;
                    });
                  },
                  child: new Text('取消')),
            ],
          ),
          new RaisedButton(onPressed: handleCreateBook, child: new Text('创建资源'))
        ],
      ),
    );
  }

  ///构建搜索记录页面
  Widget buildSearchHistory(BuildContext context) {
    List<Widget> items = <Widget>[];
    items.add(new Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text('规则记录'),
          new IconButton(
            icon: new Icon(
              Icons.delete,
              size: 18.0,
              color: Colors.black26,
            ),
            onPressed: handleDeleteHistory,
          )
        ],
      ),
    ));
    items.add(new Divider(
      height: 0.0,
    ));
    return new Container(
      color: Theme.of(context).canvasColor,
      child: new Column(
        children: items,
      ),
    );
  }

  ///构建帖子条目
  Widget buildTopicItem(BuildContext context, int index) {
    if (index >= topics.length) {
      return buildLoadMore(context);
    }
    return new TopicItem(
      selectedTopics: selectedTopics,
      inSelect: inSelect,
      topic: topics[index],
      onTap: () {
        handleTap(context, topics[index]);
      },
      onLongPress: () {
        handleLongPress(topics[index]);
      },
    );
  }

  ///构建帖子列表
  Widget buildTiebaTopiclist(BuildContext context) {
    List<Widget> items = <Widget>[];
    items.add(new Flexible(
      child: new Scrollbar(
        child: new RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: handleRefresh,
          child: new ListView.builder(
            key: listKey,
            controller: scrollController,
            physics: scrollPhysics,
            itemCount: topics.length + 1,
            itemBuilder: buildTopicItem,
          ),
        ),
      ),
    ));
    if (inSelect) {
      items.add(new Divider(
        height: 0.0,
      ));
      items.add(buildBottomBar(context));
    }
    return new Container(
      color: Theme.of(context).canvasColor,
      child: new Column(
        children: items,
      ),
    );
  }

  ///构建“加载更多”按钮
  Widget buildLoadMore(BuildContext context) {
    Widget item;
    VoidCallback callback;
    if (nextUrl == null) {
      item = new Text(
        '没有了',
        textAlign: TextAlign.center,
      );
    } else if (isLoadingMore) {
      item = new Text(
        '加载中...',
        textAlign: TextAlign.center,
      );
    } else {
      item = new Text(
        '加载更多',
        textAlign: TextAlign.center,
      );
      callback = () {
        handleLoadMore();
      };
    }
    return new ListTile(
      title: item,
      onTap: callback,
    );
  }

  Widget buildIndicator(BuildContext context) {
    return new CustomIndicator();
  }

  ///构建body
  Widget buildBody(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new Offstage(
          offstage: topics == null || topics.length == 0,
          child: buildTiebaTopiclist(context),
        ),
        new Offstage(
          offstage: !showSearch,
          child: buildSearchHistory(context),
        ),
        new Offstage(
          offstage: !isLoading,
          child: buildIndicator(context),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      handleScroll(scrollController.position);
    });
    requestTiebaTopics(callback: () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return new Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }
}

class TopicItem extends StatelessWidget {
  TopicItem(
      {Key key,
      @required this.topic,
      @required this.onTap,
      @required this.onLongPress,
      @required this.selectedTopics,
      @required this.inSelect});

  final TiebaTopic topic;
  final SelectedListModel selectedTopics;
  final bool inSelect;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  bool checkSelected() {
    if (selectedTopics.indexOf(topic) >= 0) {
      return true;
    }
    return false;
  }

  IconData getIcon() {
    if (checkSelected()) {
      return Icons.check_circle;
    }
    return Icons.radio_button_unchecked;
  }

  Color getColor(BuildContext context) {
    if (checkSelected()) {
      return Theme.of(context).primaryColor;
    }
    return Theme.of(context).disabledColor;
  }

  @override
  Widget build(BuildContext context) {
    //TODO:样式
    TextStyle style = Theme.of(context).textTheme.subhead;
    return new DecoratedBox(
      decoration: new BoxDecoration(
        border: new Border(
          bottom:
              new BorderSide(color: Theme.of(context).dividerColor, width: 0.0),
        ),
      ),
      child: new ListTile(
        title: new Text(
          topic.title,
          style: style,
        ),
        subtitle: new Text('回${topic.replyTimes}'),
        onTap: onTap,
        onLongPress: onLongPress,
        trailing: new Offstage(
            offstage: !inSelect,
            child: new Icon(
              getIcon(),
              color: getColor(context),
            )),
      ),
    );
  }
}

class SelectedListModel {
  List<TiebaTopic> _topics = <TiebaTopic>[];

  void addAll(List<TiebaTopic> topics) {
    topics.forEach((TiebaTopic topic) {
      add(topic);
    });
  }

  void add(TiebaTopic topic) {
    remove(topic);
    _topics.add(topic);
  }

  void remove(TiebaTopic topic) {
    if (_topics.length == 0) return;
    _topics.removeWhere((TiebaTopic tmp) {
      return tmp.url == topic.url;
    });
  }

  TiebaTopic operator [](int index) => _topics[index];

  int get length => _topics.length;

  int indexOf(TiebaTopic topic) {
    if (_topics.length == 0) return -1;
    return _topics.indexWhere((TiebaTopic tmp) {
      print('${tmp.url} == \n${topic.url} \n= ${tmp.url == topic.url}');
      return tmp.url == topic.url;
    });
  }

  void clear() {
    _topics.clear();
  }
}
