import 'dart:async';

import 'package:flutter/cupertino.dart';
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
    _sub.cancel();
    _countdownTimer.cancel();
    paused = true;
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
  CountdownWidget({Key? key, required this.seconds}) : super(key: key);

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(seconds.toString()));
  } 
}