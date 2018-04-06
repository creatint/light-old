import 'dart:io';
import 'package:flutter/foundation.dart';

typedef void SetterCallback<T>(T element, List<T> list);
typedef E GetterCallback<T, E>(T element, List<T> list);

class SelectedListModel<T> {
  SelectedListModel({
    @required handleRemove(T element, List<T> list),
    @required handleIndexOf(T element, List<T> list)
  })
      : _handleIndexOf = handleIndexOf,
        _handleRemove = handleRemove;

  final SetterCallback<T> _handleRemove;
  final GetterCallback<T, int> _handleIndexOf;
  List<T> _list = <T>[];

  void addAll(List<T> list) {
    list.forEach((T topic) {
      add(topic);
    });
  }

  void add(T topic) {
    remove(topic);
    _list.add(topic);
  }

  void remove(T topic) => _handleRemove(topic, _list);

  T operator [](int index) => _list[index];

  int get length => _list.length;

  int indexOf(T topic) => _handleIndexOf(topic, _list);

  void clear() {
    _list.clear();
  }

  void forEach(ValueChanged<T> call) => _list.forEach(call);

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;
}
