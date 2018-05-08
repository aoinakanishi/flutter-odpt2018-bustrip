import 'dart:async';

import 'package:flutter/material.dart';

const timeout = Duration(seconds: 3);

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Move to main screen after 3 sec.
    Timer(timeout, () {
      Navigator.of(context).pushReplacementNamed("/Main");
    });
    return DecoratedBox(
        decoration: BoxDecoration(
            color: Colors.white,
            image:
                DecorationImage(image: AssetImage("images/logo_splash.png"))));
  }
}
