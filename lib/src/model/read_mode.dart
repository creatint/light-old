import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:light/src/service/file_service.dart';

///閲讀主題類型
///[color]純色背景
///[image]圖片背景
///[texture]通過reapeat填充的背景
enum ReadModeType { color, image, texture }


class ReadMode {
  ReadMode({
    this.id,
    this.type,
    this.fontColor,
    this.backgroundColor,
    this.image_uri,
  });

  ///用於解析從數據庫讀取的數據
  ReadMode.fromMap(Map map)
      : this.id = int.parse(map['id']),
        this.type = ReadModeType.values
            .firstWhere((v) => v.toString() == 'ReadModeType.' + map['type']),
        this.fontColor = new Color(int.parse(map['font_color'])),
        this.backgroundColor = map['background_color'],
        this.image_uri = map['image_uri'];

  final int id;
  final ReadModeType type;
  final Color fontColor;
  final Color backgroundColor;
  final String image_uri;

  BoxFit get fit => type == ReadModeType.image
      ? BoxFit.cover
      : type == ReadModeType.texture ? BoxFit.none : null;

  ImageRepeat get repeat => type == ReadModeType.image
      ? ImageRepeat.noRepeat
      : type == ReadModeType.texture ? ImageRepeat.repeat : null;

  DecorationImage get image => null != image_uri
      ? new DecorationImage(
          fit: fit, repeat: repeat, image: new AssetImage(image_uri))
      : null;
}
