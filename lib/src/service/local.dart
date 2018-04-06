import 'dart:async';
import 'package:light/src/model/book.dart';

import 'package:light/src/service/mock_book.dart';

class Local {
  Future<List<Book>> getBooks(String word) async {
    return mockBooks;
  }
}