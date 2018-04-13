import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:light/src/service/config.dart';

class DB {
  static DB _instance;
  static Config _config;
  static Database _database;

  DB._();

  factory DB([String name = 'default']) {
    if (null != _instance)
      return _instance;
    else
      return null;
  }

  static Future<DB> getInstance([Config config]) async {
    try {
      if (null == _config) {
        _config = config;
      }
      if (null == _database) {
        if (null == _config) {
          return null;
        }
        Directory dir = await getApplicationDocumentsDirectory();
        String path = join(dir.path, _config.getString('database'));
        if (new File(path).existsSync()) {
          _database = await openDatabase(path, version: 3,
              onCreate: (Database db, int version) async {
            // When creating the db, create the table
            print('数据库连接成功 version: $version, path: $path');
          });
        } else {
          return null;
        }
      }
      if (null == _instance) {
        _instance = new DB._();
        return _instance;
      }
      return _instance;
    } catch (e) {
      print('DB加载异常：$e');
      return null;
    }
  }

  ///INSERT data
  Future<int> insert(String table, Map<String, dynamic> values,
      {String nullColumnHack, ConflictAlgorithm conflictAlgorithm}) {
    return _database.insert(table, values,
        nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm);
  }

  ///SELECT data
  Future<List<Map<String, dynamic>>> query(String table,
      {bool distinct,
      List<String> columns,
      String where,
      List whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) {
    return _database.query(table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
  }

  Future<List<Map>> rawQuery(String query) {
    return _database.rawQuery(query);
  }

  Future<Null> execute(String query, List arguments) {
    return _database.execute(query, arguments);
  }
}
