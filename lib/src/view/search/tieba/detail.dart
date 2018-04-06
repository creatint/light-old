import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart' as urll;

import 'package:light/src/service/file_service.dart';
import 'package:light/src/view/custom_page_route.dart';
import 'package:light/src/view/custom_indicator.dart';
import 'package:light/src/model/tieba_topic.dart';
import 'package:light/src/model/tieba_post.dart';
import 'package:light/src/view/parts/dialog_item.dart';
import 'package:light/src/parts/image_view.dart';

enum DialogAction { copy }

class Detail extends StatefulWidget {
  Detail({
    @required this.topic,
  });

  final TiebaTopic topic;

  @override
  DetailState createState() => new DetailState();
}

class DetailState extends State<Detail> {
  final Key listKey = new Key('list');
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final RegExp regFormatContent = new RegExp(r'<br>');
  final RegExp regGetUrlPiece = new RegExp(r'^(.*)(m\?k.+)$');
  final RegExp regGetNextUrl = new RegExp(r'\?pn=(\d+)');
  final RegExp regReplaceUrl = new RegExp(r'(m\?k.+)$');
  final List<TiebaPost> posts = <TiebaPost>[];
  final ScrollController scrollController = new ScrollController();
  final ScrollPhysics scrollPhysics = new BouncingScrollPhysics();
  String url = 'https://tieba.baidu.com/p/'; //当前请求的url
  bool isLoading = true;
  bool isLoadingMore = false;
  String nextUrl;
  int currentPN = 1;
  int maxPN;

  ///根据页码构造链接
  String getUrl(int pn) {
    return url.replaceFirst(regGetNextUrl, '?pn=$pn');
  }

  ///处理点击事件
  void handleTap(BuildContext context, TiebaPost topic) {
    print('handleTap');
//    Navigator.of(context).push(new CustomPageRoute(
//        builder: new WebviewScaffold(url: widget.topic.url)));
//    print(topic.title);
//    print(topic.url);
//    Navigator.of(context).push(new CustomPageRoute(
//        builder: (BuildContext context) =>
//        new Detail(topic: topic)
//    ));
  }

  ///处理长按事件 复制文本
  void handleLongPress(BuildContext context, TiebaPost post) {
    ThemeData theme = Theme.of(context);
    print('handleLongPress');
    print(post.getAuthor());
    showDialog<DialogAction>(
        context: context,
        child: new SimpleDialog(
          title: new Text('操作'),
          children: <Widget>[
            new DialogItem(
              icon: Icons.content_copy,
              color: theme.primaryColor,
              text: '复制',
              onPressed: () {
                Navigator.pop(context, DialogAction.copy);
              },
            )
          ],
        )).then<Null>((DialogAction action) {
      if (action == null) {
        print('无操作');
        return;
      }
      switch (action) {
        case DialogAction.copy:
          print('复制');
          Clipboard
              .setData(new ClipboardData(text: post.getContent()))
              .then<Null>((value) {
            print(value);
            scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: new Text(
              '已复制到剪贴板',
              textAlign: TextAlign.center,
            )));
          });
          break;
      }
    });
  }

  ///处理加载更多事件
  void handleLoadMore() {
    print('handleLoadMore');
    if (currentPN == maxPN) {
      return;
    }
    setState(() {
      isLoadingMore = true;
      url = getUrl(++currentPN);
    });
    requestTiebaPosts(
        url: nextUrl,
        callback: () {
          setState(() {
            isLoadingMore = false;
          });
        });
  }

  ///处理刷新事件
  Future<Null> handleRefresh() async {
    setState(() {
      currentPN = 1;
      url = getUrl(currentPN);
      posts.clear();
      isLoading = true;
    });
    return requestTiebaPosts(callback: () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void handleScroll(ScrollPosition position) {
    if (!isLoadingMore && (position.pixels - position.maxScrollExtent) > 80) {
      handleLoadMore();
    }
  }

  void handleImageTap(Image image) {
    Navigator.push(
        context,
        new CustomPageRoute(
            builder: (BuildContext context) => new ImageView(
                  image: image,
                )));
  }

  ///加载帖子
  Future<Null> requestTiebaPosts({String url, VoidCallback callback}) async {
    print('访问帖子：$url');
    return get(url).then((response) async {
      dom.Document document = parser.parse(response.body);
      List<dom.Element> postElements =
          document.body.querySelectorAll('div.l_post');
      if (maxPN == null) {
        maxPN = int.parse(document.body
            .querySelector('li.l_reply_num>span.red:last-child')
            ?.innerHtml);
        print('maxPN = $maxPN\ncurrentPn = $currentPN');
      }
      postElements.forEach((post) {
        String datetime =
            post.querySelector('span.tail-info:last-child')?.innerHtml;
//        print('datetime: $datetime');
        String avatarUrl = post
            .querySelector('a.p_author_face>img')
            ?.attributes['data-tb-lazyload'];
        if (null == avatarUrl || avatarUrl.isEmpty) {
          avatarUrl =
              post.querySelector('a.p_author_face>img')?.attributes['src'];
        }
        posts.add(new TiebaPost.json(
            raw: post.attributes['data-field'],
            datetime: datetime,
            avatarUrl: avatarUrl,
            referer: url));
      });

      //获取下一页链接
      if (currentPN < maxPN) {
        nextUrl = getUrl(++currentPN);
      }
      print('nextUrl=$nextUrl');
    }).whenComplete(() {
      return callback();
    });
  }

  ///构建AppBar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Text(widget.topic.title),
    );
  }

  Widget buildPostItem(BuildContext context, index) {
    print('buildPostItem');
    if (index >= posts?.length) {
      return buildLoadMore(context);
    } else {
      return new PostItem(
        post: posts[index],
        onTap: () {
          handleTap(context, posts[index]);
        },
        onLongPress: () {
//          handleLongPress(context, posts[index]);
        },
        onImageTap: handleImageTap,
      );
    }
  }

  Widget buildPostList(BuildContext context) {
    return new Offstage(
      offstage: null == posts && posts.isEmpty,
      child: new Container(
        color: Theme.of(context).canvasColor,
        child: new ListView.builder(
          key: listKey,
          controller: scrollController,
          physics: scrollPhysics,
          itemCount: posts.length + 1,
          itemBuilder: buildPostItem,
        ),
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
    return new Offstage(offstage: !isLoading, child: new CustomIndicator());
  }

  ///构建Body
  Widget buildBody(BuildContext context) {
    List<Widget> pages = <Widget>[];
    pages.add(buildPostList(context));
    pages.add(buildIndicator(context));
    return new Stack(
      children: pages,
    );
  }

  @override
  void initState() {
    super.initState();

    url += '${widget.topic.id}?pn=$currentPN';
    requestTiebaPosts(
        url: url,
        callback: () {
          setState(() {
            isLoading = false;
          });
        });

    scrollController.addListener(() {
      handleScroll(scrollController.position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }
}

///回复帖子
class PostItem extends StatelessWidget {
  PostItem(
      {Key key,
      @required this.post,
      @required this.onTap,
      @required this.onLongPress,
      @required this.onImageTap});

  final TiebaPost post;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<Image> onImageTap;

  List<Widget> parseContent(String str, BuildContext context) {
    final RegExp regStrong =
        new RegExp(r'<strong>[^<]+</strong>', caseSensitive: false);
    final RegExp regStrongText = new RegExp(r'<strong>([^<]+)</strong>');
    final RegExp regAnchor =
        new RegExp(r'<a[^>]+>[^<]+</a>', caseSensitive: false);
    final RegExp regAnchorHref = new RegExp(r'href="([^"]+)"');
    final RegExp regAnchorText = new RegExp(r'<a[^>]+>([^>]+)</a>');
    final RegExp regImage = new RegExp(r'<img[^>]+>', caseSensitive: false);
    final RegExp regImageSrc = new RegExp(r'src="([^"]+)"');
    final List<Widget> list = <Widget>[];
    final TextStyle style = Theme.of(context).textTheme.body1;
    final TextStyle strongStyle = new TextStyle(fontWeight: FontWeight.bold);
    final TextStyle anchorStyle =
        new TextStyle(color: Colors.blue, decoration: TextDecoration.underline);

    //插入<br>元素
    str = str.replaceAllMapped(new RegExp(r'<strong>([^<]+)</strong>'),
        (Match m) => '<br><strong>${m.group(1)}</strong><br>');
    str = str.replaceAllMapped(new RegExp(r'<img([^>]+)>'),
        ((Match m) => '<br><img${m.group(1)}><br>'));
    str = str.replaceAllMapped(new RegExp(r'<a([^>]+)>([^<]+)</a>'),
        ((Match m) => '<br><a${m.group(1)}>${m.group(2)}</a><br>'));

    //多个<br>元素缩减为1个
    str = str.replaceAll(new RegExp(r'(<br>)\1+'), '<br>');

    //以<br>元素分割内容,删掉空字符串
    List<String> strList = str.split('<br>');
    strList.removeWhere((s) => null == s || s.isEmpty);
    strList.forEach((String str) {
      if (regAnchor.hasMatch(str)) {
        //链接
        String url = regAnchorHref.firstMatch(str)?.group(1);
        String text = regAnchorText.firstMatch(str)?.group(1);
        print(url);
        if (url == null) return;
        list.add(new GestureDetector(
            onTap: () async {
              try {
                if (await urll.canLaunch(str)) {
                  await urll.launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              } catch (e) {
                print('Error $e');
              }
            },
            child: new Text(text, style: anchorStyle)));
      } else if (regImage.hasMatch(str)) {
        //图片
        String src = regImageSrc.firstMatch(str)?.group(1);
        Image image = new Image.network(src);
        if (src == null) return;
        list.add(new Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: new GestureDetector(
              child: image,
              onTap: () {
                onImageTap(image);
              },
            )));
      } else if (regStrong.hasMatch(str)) {
        String text = regStrongText.firstMatch(str)?.group(1);
        list.add(new Text(
          text,
          style: strongStyle,
        ));
      } else {
        //文字
        list.add(new Text(
          str,
          style: style,
        ));
      }
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    //TODO:样式
//    TextStyle style = Theme.of(context).textTheme.subhead;
    TextStyle style = Theme.of(context).textTheme.subhead;
    return new DecoratedBox(
      decoration: new BoxDecoration(
        border: new Border(
          bottom:
              new BorderSide(color: Theme.of(context).dividerColor, width: 0.0),
        ),
      ),
      child: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: new Row(
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: new CircleAvatar(
                      child: new Builder(
                        builder: (BuildContext context) => post.getAvatar(),
                      ),
//                      child: new Text(
//                        post.getAuthor()[0],
//                        style: new TextStyle(
//                            color: Theme.of(context).primaryColor),
//                      ),
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  new Column(
                    children: <Widget>[
                      new Text(
                        post.getAuthor(),
                        style: new TextStyle(),
                      ),
                      new Text('第${post.getFlour()}楼 ${post.getDatetime()}',
                          style: new TextStyle(
                              color: Theme.of(context).hintColor)),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            new GestureDetector(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: parseContent(post.getContent(), context),
              ),
              onTap: onTap,
              onLongPress: onLongPress,
            ),
          ],
        ),
      ),
    );
  }
}
