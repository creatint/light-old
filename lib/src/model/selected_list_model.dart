//import 'dart:io';
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

  List<T> get list => _list;

  void addAll(List<T> list) {
    list.forEach((T ele) {
      add(ele);
    });
  }

  void add(T ele) {
    remove(ele);
    _list.add(ele);
  }

  void remove(T ele) => _handleRemove(ele, _list);

  T operator [](int index) => _list[index];

  int get length => _list.length;

  int indexOf(T ele) => _handleIndexOf(ele, _list);

  void clear() {
    _list.clear();
  }

  void forEach(ValueChanged<T> call) => _list.forEach(call);

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;
}
