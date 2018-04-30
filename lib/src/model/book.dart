import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'package:light/src/service/file_service.dart';
import 'package:light/src/service/book_service.dart';

///book数据可能是从线上获取，也可能是本地存储
///无论从线上线下获取到的book数据，封面不一定存在
/// 225 130 101  599
enum BookType { txt, epub, pdf, url, urls }

class Book {
  Book(
      {@required this.title,
      this.description,
      this.coverUri,
      this.uri,
      this.type,
      this.createAt,
      this.updateAt});

  Book.fromEntity({@required FileSystemEntity entity})
      : assert(null != entity),
        title =
            new RegExp(r'([^/]+)\.[^./]+$').firstMatch(entity.path).group(1),
        description = null,
        coverUri = null,
        uri = entity.path,
        type = getSuffix(entity),
        createAt = new DateTime.now().toIso8601String(),
        updateAt = new DateTime.now().toIso8601String();

  final String title;
  final String description;
  final String coverUri;
  final String uri;
  final String type;
  final String createAt;
  final String updateAt;
  BookService bookService;

  Book.fromMap({@required Map<String, dynamic> map})
      : assert(null != map),
        title = map['title'],
        description = map['description'],
        coverUri = map['cover_uri'],
        uri = map['uri'],
        type = map['type'],
        createAt = map['create_at'],
        updateAt = map['update_at'];

  @override
  String toString() => '{title: $title, type: $type, uri: $uri}\n';

//  BookType get bookType => BookType.values.firstWhere((t) => t.toString() == this.type);
  BookType get bookType => BookType.values.firstWhere((t) {
//        print(t.toString());
//        print(this.type);
        return t.toString() == 'BookType.' + this.type;
      });

  Map<String, String> getMap() {
    return {
      'title': title,
      'description': description,
      'cover_uri': coverUri,
      'type': type,
      'uri': uri,
      'create_at': createAt
    };
  }

  /// 用于记录分页数据
  String get recordsName => title + '_records';

  /// 用于纪录阅读进度
  String get processName => title + '_process';

  Future<int> delete() async {
    if (null == bookService) {
      bookService = new BookService();
    }
    return await bookService.deleteBook(this);
  }
}

/// 章节数据
class Chapter {
  Chapter(
      {@required this.id,
      @required this.title,
      @required this.offset,
      @required this.length});

  List<Chapter> subChapters = <Chapter>[];

  final int id;
  final String title;
  final int offset;
  final int length;

  @override
  String toString() {
    return 'Chapter{id: $id, title: $title, offset: $offset, length: $length}';
  }
}

BookType getBookType(FileSystemEntity entity) {
  String suffix = getSuffix(entity);
  return BookType.values
      .firstWhere((t) => t.toString() == 'BookType.' + suffix);
}
