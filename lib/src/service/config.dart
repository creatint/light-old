import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:options_file/options_file.dart';

class Config {
  static Config _instance;
  static OptionsFile _optionFile;

  static Future<Config> getInstance1() async {
    try {
      if (null == _optionFile) {
        Directory dir = await getApplicationDocumentsDirectory();

        String path = join(dir.path, 'config.ini');
        if (!(new File(path).existsSync())) {
//        throw new FileSystemException('config.ini不存在 $path');
          print('config.ini不存在 $path');
          return null;
        }
        _optionFile = new OptionsFile(path);
      }
      if (null == _instance) {
        _instance = new Config._();
        return _instance;
      }
      return _instance;
    } catch(e) {
      print('Config加载异常：$e');
      return null;
    }
  }

  Config._() {}

  String getString(String key) {
    return _optionFile.getString(key);
  }

  int getInt(String key) {
    return _optionFile.getInt(key);
  }

  bool getBool(String key) {
    return getString(key) == 'true';
  }

  double getDouble(String key) {
    return double.parse(getString(key));
  }
}
