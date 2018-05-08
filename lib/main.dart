import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:odpt/screen/main.dart';
import 'package:odpt/screen/saved.dart';
import 'package:odpt/screen/splash.dart';

var location = new Location();

Future main() async {
  // keep screen orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Screen routes
  runApp(MaterialApp(
    home: Splash(),
    routes: <String, WidgetBuilder>{
      "/Main": (BuildContext context) => Main(),
      "/Saved": (BuildContext context) => Saved(),
    },
  ));
}
