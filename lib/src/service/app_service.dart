import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show required;

class AppService {
  static AppService _cache;

  AppService._internal({@required this.prefs})
      : streamController = new StreamController<dynamic>.broadcast();

  factory AppService({SharedPreferences prefs}) {
    if (null == _cache) {
      _cache = new AppService._internal(prefs: prefs);
    }
    return _cache;
  }

  /// SharedPreferences实例
  final SharedPreferences prefs;

  /// 流控制器
  final StreamController<dynamic> streamController;

  /// 获得stream
  Stream get stream => streamController.stream;

  /// 发送事件
  void add(value) => streamController.add(value);

}
