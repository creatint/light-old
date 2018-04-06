import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';

import 'package:light/src/service/baidu_service.dart';

class TiebaPost {
  TiebaPost({
    this.data,
  }) {
    document = parse(data);
  }

  TiebaPost.json(
      {@required this.raw, this.datetime, this.avatarUrl, this.referer}) {
    data = JSON.decode(raw);
    author = data['author'];
    content = data['content']['content'];
    flour = data['content']['post_no'];
    commentNum = data['content']['comment_num'];
  }

  String referer;
  String raw;
  Map data;
  Document document;

  String avatarUrl;
  Map author;
  int commentNum;
  String content;
  String datetime;
  int flour;
  RegExp regFlour = new RegExp(r'^(\d+)楼\.');

  String getFlour() {
    return flour.toString();
//    flour = regFlour.firstMatch(data).group(1);
//    return flour;
  }

  String getNormalUrl(String url) {
    if (new RegExp(r'^//').hasMatch(url)) {
      return 'https:' + url;
    }
    return url;
  }

  Image getAvatar() {
    return getImage(getNormalUrl(avatarUrl), getAuthor(), referer);
  }

  String getAuthor() {
    return author['user_name'];
//    author = document.querySelector('span.g>a').innerHtml;
//    return author;
  }

  String getDatetime() {
    return datetime;
//    datetime = document.querySelector('span.b').innerHtml;
//    return datetime;
  }

  String getContent() {
    return content;
//    content = document.firstChild.text.replaceFirst(regFlour, '').split('\n');
//    content.removeAt(content.length - 1);
//    return content.join('\n');
  }
}
