import 'package:flutter/material.dart';
import 'package:http/http.dart';

Map cache = {};

getImage(String url, String key, [String referer]) {
  if (cache[key] != null) {
    print('有缓存');
    return cache[key];
  }
  print('无缓存 name = $key \n url = $url \n referer = $referer');
  cache[key] = new Image.network(url, headers: {'referer': referer});
  return cache[key];
}
