import 'package:flutter/foundation.dart';

class TiebaTopic{
  TiebaTopic({
    @required this.id,
    @required this.title,
    @required this.url,
    @required this.tiebaUrl,
    @required this.clickTimes,
    @required this.replyTimes
  });

  final int id;
  final String title;
  final String url;
  final String tiebaUrl;
  final int clickTimes;
  final int replyTimes;
}