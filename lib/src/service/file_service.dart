import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum FileType { TEXT, EPUB, PDF, OTHER, NOT_FOUND, DIRECTORY }

RegExp _regFileType = new RegExp(r'([^.\\/]+)$');
RegExp _regTXT = new RegExp(r'txt');
RegExp _regPDF = new RegExp(r'pdf');
RegExp _regEPUB = new RegExp(r'epub');
RegExp _regName = new RegExp(r'(.+)[^.]+$');
RegExp _regSuffix = new RegExp(r'.*\.([^.\\/]+)$');
RegExp _regBasename = new RegExp(r'[^/\\]+$');

FileType getType(FileSystemEntity entity) {
  if (entity.existsSync()) {
    if (FileSystemEntity.isDirectorySync(entity.path)) {
      return FileType.DIRECTORY;
    } else {
      String name = getBasename(entity.path);
      FileType type;
      if (name == null || name.isEmpty) {
        type = FileType.OTHER;
      }
      String suffix = _regFileType.firstMatch(name)?.group(1);
      if (null == suffix || suffix.isEmpty) {
        type = FileType.OTHER;
      } else if (_regTXT.hasMatch(suffix))
        type = FileType.TEXT;
      else if (_regPDF.hasMatch(suffix))
        type = FileType.PDF;
      else if (_regEPUB.hasMatch(suffix))
        type = FileType.EPUB;
      else
        type = FileType.OTHER;
      return type;
    }
  }
  return FileType.NOT_FOUND;
}

String getBasename(var file) {
  if (file is String) {
    return _regBasename.firstMatch(file)?.group(0);
  } else if (file is Directory || file is FileSystemEntity) {
    return _regBasename.firstMatch(file.path)?.group(0);
  } else {
    return '';
  }
}

String getName(var file) {
  String baseName = getBasename(file);
//  print('baseName: $baseName');
  String name = _regName.firstMatch(baseName)?.group(1);
//  print(_regName.firstMatch(baseName));
  return name;
//  return _regName.firstMatch(baseName)?.group(1);
}

String getSuffix(var file) {
  String baseName = getBasename(file);
  String suffix = _regSuffix.firstMatch(baseName)?.group(1);
//  print(_regSuffix.firstMatch(baseName).group(0));
//  print(_regSuffix.firstMatch(baseName).group(1));
  return suffix;
}

Future<Null> writeFile(String content, String name) async {
  Directory dir = await getExternalStorageDirectory();
  String path = join(dir.path, 'Yotaku', name);
  try {
    print('写入文件 path=$path\ncontent=$content');
    File file = new File(path);
    file.writeAsStringSync(content);
    return null;
  } catch (e) {
    print('文件写入失败：$e');
    if (dir.existsSync()) {
      print('文件夹存在：${dir.path}');
    } else {
      print('文件夹不存在：${dir.path}');
    }
    return null;
  }
}

bool isDirectory(FileSystemEntity entity) {
  return FileSystemEntity.isDirectorySync(entity.path);
}

class FileService {
  static final Map<String, FileService> _cache = <String, FileService>{};
  static final Future<Directory> external = getExternalStorageDirectory();

  factory FileService([String name = 'default']) {
    if (_cache.containsKey(name)) {
      return _cache[name];
    } else {
      _cache[name] = new FileService._internal();
      return _cache[name];
    }
  }

  FileService._internal();

  Future<T> readFile<T>(String name) async {
    try {
      return external.then<T>((Directory dir) {
        String path = join(dir.path, 'Yotaku', name);
        print(path);
        File file = new File(path);
        print('flag');
        return file.readAsStringSync() as T;
      });
    } catch (e) {
      print('文件读取失败：$e');
      return null;
    }
  }
}

Image getImage(String uri) {
  RegExp regasset = new RegExp(r'^asset');
  RegExp regurl = new RegExp(r'^http');
  RegExp regfile = new RegExp(r'^/storage');
  if (regasset.hasMatch(uri)) {
    return new Image.asset(uri);
  } else if (regurl.hasMatch(uri)) {
    return new Image.network(uri);
  } else if (regfile.hasMatch(uri)) {
    return new Image.file(new File(uri));
  }
  return null;
}

String charsetDetector(RandomAccessFile file) {
  String charset;
  List<int> bytes = file.readSync(3);
  int length = file.lengthSync();
  bool isLatin1 = true;
  bool isUtf8 = true;
  if (null != bytes &&
      bytes.length == 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    isLatin1 = false;
  } else if (null != bytes && bytes.isNotEmpty) {
    //不带bom头，可能是gbk,latin1,utf8,big5
    bytes = file.readSync(100 > length ? length : 100);
    int i = 0;
    do {
      if (bytes[i] > 127) {
        isLatin1 = false;
      }
      if ((bytes[i] & 0xC0) != 0x80) {
        isUtf8 = false;
      }
      i++;
    } while (i < bytes.length);
  }
  if (!isLatin1 && !isUtf8) {
    charset = 'gbk';
  } else if (!isLatin1 && isUtf8) {
    charset = 'utf8';
  } else if (isLatin1 && !isUtf8) {
    charset = 'latin1';
  }
  return charset;
}
