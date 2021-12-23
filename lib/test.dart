import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/countdown.dart';
import 'package:quiver/async.dart';



class Test extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestState();
}

class _TestState extends State<Test> {
  _TestState() {
    countdown = Countdown(onTick: onCountdownTick, onDone: onCountdownOver, startTime: 10,);
  }

  bool paused = true;

  int currentTime = 10;
  late Countdown countdown;

  void onCountdownTick(int current) {
    print("TICK TOCK");
      setState(() {
        currentTime = current;
      });
  }

  void onCountdownOver() {
    print("GAME OVER");
  }
 
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text("test"),
            Text(currentTime.toString()),
            ElevatedButton(
              onPressed: () {
                countdown.toggle();
              },
            child: Text("toggle pause"),
          ),
          ],
        )
      )
    );
  }
}