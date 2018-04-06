import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:light/src/model/book.dart';

bool mock = true;

Future<List<Book>> getOnlineBooksAll(String word) {
  String url = '';

  if (mock) {
    return new Future<List<Book>>.delayed(new Duration(milliseconds: 2000), () => <Book>[]);
    return new Future<List<Book>>.delayed(new Duration(milliseconds: 2000), () => <Book>[
      new Book(title: '书1'),
      new Book(title: '书2'),
      new Book(title: '书3'),
    ]);
  }
  return http.get(url).then((response) {
    return JSON.decode(response.body);
  });
}