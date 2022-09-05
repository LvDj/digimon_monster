import 'dart:async';

import 'package:digimon_monster/Game/Game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DMLoadingPage extends StatefulWidget {
  double _progressValue = 0;
  @override
  State<StatefulWidget> createState() {
    return _DMLoadingState();
  }
}

class _DMLoadingState extends State<DMLoadingPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _value;
  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 5000), vsync: this);
    _value = new Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    timerAction();
  }

  timerAction() {
    const timeout = const Duration(milliseconds: 500);
    Timer(timeout, () {
      var i = widget._progressValue;
      if (widget._progressValue < 1) {
        if (widget._progressValue > 1) {
          widget._progressValue = 1;
        }
        widget._progressValue += 0.1;
        _controller.animateTo(widget._progressValue);
        timerAction();
      } else {
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return DMGamePage();
        // }));
        Navigator.of(context).pushNamed("DMGamePage");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Spacer(),
            Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 10,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: ClipRRect(
                child: LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  value: _value.value,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
