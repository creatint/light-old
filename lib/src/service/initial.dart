import 'dart:io';
import 'dart:async';
//import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:light/src/service/config.dart';
import 'package:light/src/service/db.dart';

///判断是否已经安装
Future<bool> isInstalled(SharedPreferences prefs) async {
//  return false;
  if (prefs.getBool('installed') != null && prefs.getBool('installed') == true)
    return true;
  return false;
}

///执行安装
Future<SharedPreferences> initial() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (await isInstalled(prefs)) {
    print('Installed, skip......');
    return prefs;
  }
  print('Installing......');

  //检查权限
  if (!(await checkPermissions())) {
    return prefs;
  }

  Directory directory = await getApplicationDocumentsDirectory();

  try {
    Config config = await createConfig(directory);
    if (null == config) {
      throw new Exception('复制config失败');
    }
    DB db = await createDB(directory, config);
    if (null == db) {
      throw new Exception('复制db失败');
    }
//    bool dirRes = await createDirectory(config);
//    if (!dirRes) {
//      throw new Exception('创建文件夹失败');
//    }
    bool testRes = await test(dir: directory, db: db, config: config);
    if (!testRes) {
      throw new Exception('测试失败');
    }
//    createConfig(directory).then((Config config) {
//      print('flag1');
//      createDB(directory, config).then((DB db) {
//        print('flag2');
//        createDirectory(config).then((done) {
//          print('flag3');
//          if (done)
//            test(dir: directory, db: db, config: config).then((_) {
//              return prefs;
//            });
//        });
//      });
//    });
    prefs.setBool('installed', true);
  } on FileSystemException catch (e) {
    print('需要文件读写权限 $e');
  } catch (e) {
    print('Install failed. $e');
  }
  return prefs;
}

///测试权限
Future<bool> checkPermissions() async {
  Directory dir = await getApplicationDocumentsDirectory();
  String path = join(dir.path, 'test.txt');
  try {
    print('尝试写入测试文件 path=$path');
    File file = new File(path);
    file.writeAsStringSync('test');
    if (file.readAsStringSync() == 'test') {
      print('测试文件写入成功');
      return true;
    } else {
      print('测试写入文件失败');
      return false;
    }
  } catch (e) {
    print('测试文件写入失败：$e');
    if (dir.existsSync()) {
      print('文件夹存在：${dir.path}');
    } else {
      print('文件夹存在：${dir.path}');
    }
    if (new File(path).existsSync()) {
      print('文件存在：$path');
      List<FileSystemEntity> list = dir.listSync();
      list.forEach((FileSystemEntity entity) {
        print(entity.path);
      });
    } else {
      print('文件不存在：$path');
    }
    return false;
  }
}

///创建配置文件
Future<Config> createConfig(Directory dir) async {
  try {
    String path = join(dir.path, 'config.ini');
    print('正在复制配置文件config.ini到$path');
    ByteData data = await rootBundle.load(join('assets', 'config.ini'));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    new File(path).writeAsBytesSync(bytes);
    return Config.getInstance1();
  } catch (e) {
    print('创建配置文件失败：$e');
    return null;
  }
}

///创建数据库
Future<DB> createDB(Directory dir, Config config) async {
  print('createDB');
  try {
    //数据库路径
    String path = join(dir.path, config.getString('database'));
    //创建路径
    await new Directory(dirname(path)).create(recursive: true);

    //删除数据库
    if (new File(path).existsSync()) {
      await deleteDatabase(path);
    }
    print('flag1.5');

    //读取asset资源
    ByteData dbData = await rootBundle.load(join('assets', 'light.db'));
    List<int> dbBytes =
        dbData.buffer.asUint8List(dbData.offsetInBytes, dbData.lengthInBytes);
    //写入app文件夹
    await new File(path).writeAsBytes(dbBytes);
    print('flag1.6');

    //新建数据库并打开
    Database db = await openDatabase(path, version: 3,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      print('数据库创建成功 version: $version, path: $path');
      await db.execute(
          "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
    });

// Insert some records in a transaction
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
      print("inserted1: $id1");
      int id2 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
          ["another name", 12345678, 3.1416]);
      print("inserted2: $id2");
    });

// Update some record
    int count = await db.rawUpdate(
        'UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',
        ["updated name", "9876", "some name"]);
    print("updated: $count");

// Get the records
    List<Map> list = await db.rawQuery('SELECT * FROM Test');
    List<Map> expectedList = [
      {"id": 1, "name": "updated name", "value": 9876, "num": 456.789},
      {"id": 2, "name": "another name", "value": 12345678, "num": 3.1416}
    ];
    print(list);
    print(expectedList);

// Count the records
    count =
        Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM Test"));
    assert(count == 2);

// Delete a record
    count =
        await db.rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
    assert(count == 1);

    db.close();

    return DB.getInstance(config);
  } catch (e) {
    print('创建数据库失败：$e');
    return null;
  }
}

/// 创建存储文件夹
Future<bool> createDirectory(Config config) async {
  Directory exDir = await getExternalStorageDirectory();
  try {
    String path = join(exDir.path, config.getString('storage'));
    if (!FileSystemEntity.isDirectorySync(path)) {
      Directory rootDir = new Directory(path);
      rootDir.createSync(recursive: true);
    }
    return true;
  } catch (e) {
    print('创建存储文件夹失败：$e');
    return false;
  }
}

///测试
Future<bool> test({Directory dir, DB db, Config config}) async {
  print('Install finished.');
  print('测试：');

  try {
    //遍历当前文件夹
    print('Files in ${dir.path}:');
    List fileList = dir.listSync();
    fileList.forEach((entity) {
      print(entity.path);
    });

    //读取配置文件
    print('读取配置文件:');
    Config config = await Config.getInstance1();
    print('version = ' + config.getString('version'));

    //写入数据库
    print('写入数据库');
    int id = await db.insert('collection', {'name': 'test name', 'type': '0'});
    print('写入数据id=$id');

    //查询数据库
    print('查询数据库:');
    List<Map> list = await db.rawQuery('select * from collection where id=$id');
    print(list);
  } catch (e) {
    print('测试出错：$e');
  }
  return true;
}
