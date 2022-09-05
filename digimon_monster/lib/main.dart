import 'package:digimon_monster/Game/Game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Loading/dm_loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, //全屏时旋转方向，左边
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DMGamePage(), //DMLoadingPage(),
      routes: {
        "DMGamePage": (context) => DMGamePage(),
      },
    );
  }
}
