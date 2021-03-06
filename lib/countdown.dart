import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/async.dart';

class Countdown {
  Countdown({required this.startTime, required this.onDone, required this.onTick}) {
    _current = startTime;
  }

  bool paused = true;
  bool isDone = false;
  int startTime;
  late int _current;
  Function() onDone;
  Function(int current) onTick;

  late CountdownTimer _countdownTimer;
  late StreamSubscription<CountdownTimer> _sub;
  
  void start() {
    print("RESUMING");
    var start = _current;
    _countdownTimer = new CountdownTimer(
      new Duration(seconds: start),
      new Duration(seconds: 1),
    );
    _sub = _countdownTimer.listen(null);
    _sub.onData((duration) {
      _current = start - duration.elapsed.inSeconds;
      
      onTick(_current);
    });

    _sub.onDone(() {
      onDone();
      _sub.cancel();
      isDone = true;
    });
    paused = false;
  }

  void pause() {
    print("pausing");
    if(!paused) {
      _sub.cancel();
      _countdownTimer.cancel();
    }
    paused = true;
  }

  void stop() {
    print("stopping");
    _sub.cancel();
    _countdownTimer.cancel();
  }

  void toggle() {
    if(paused) {
      start();
    } else {
      pause();
    }
  }

  Duration elapsed() {
    return _countdownTimer.elapsed;
  }
}

class CountdownWidget extends StatelessWidget {
  CountdownWidget({Key? key, required this.seconds, required this.initial}) : super(key: key);

  final int seconds;
  final int initial;

  @override
  Widget build(BuildContext context) {
    // return Center(child: Text(seconds.toString()+'/'+initial.toString()));
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width*.1,
      height: width*.1,
      child: Stack(
        children: [
          Center(
            child: Text(seconds.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              )
            ),
          Center(
            child: CircularProgressIndicator(
              value: seconds/initial,
              backgroundColor: Colors.transparent,
              color: Colors.white,
            )
          )
        ]
      )
    );
  } 
}