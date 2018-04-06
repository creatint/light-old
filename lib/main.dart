import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:light/src/service/initial.dart';
import 'package:light/src/service/config.dart';
import 'package:light/src/service/db.dart';
import 'package:light/src/app.dart';

Future<SharedPreferences> prefs;

void main() async {
  SharedPreferences prefs = await initial();
  Config config = await Config.getInstance1();
  DB db = await DB.getInstance(config);
  runApp(new App(prefs: prefs, config: config, db: db,));
//  return;
//  initial().then((SharedPreferences prefs) {
//    Config.getInstance1().then((Config config){
//      DB.getInstance(config).then((DB db) {
//        runApp(new App(
//          prefs: prefs,
//          config: config,
//          db: db,
//        ));
//      });
//    });
//  });
}
