import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kanji_memory_hint/audio_repository/audio.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/countdown.dart';
import 'package:kanji_memory_hint/database/kanji.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/database/user_point.dart';
import 'package:kanji_memory_hint/reward/save_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';



class Test extends StatefulWidget {
  
  Future<UserPoint> getUserPoints() async {
    return SQLRepo.userPoints.get();
  }
  
  @override
  State<StatefulWidget> createState() => _TestState();
}

class _TestState extends State<Test> {
  _TestState() {
    countdown = Countdown(onTick: onCountdownTick, onDone: onCountdownOver, startTime: 10,);
  }

  var points;

  bool paused = true;
  int currentTime = 10;

  late Countdown countdown;

  @override
  void initState() {
    super.initState();

    points = widget.getUserPoints();
  }

  void onCountdownTick(int current) {
    print("TICK TOCK");
      setState(() {
        currentTime = current;
      });
  }

  void onCountdownOver() {
    print("GAME OVER");
  }

  Future<String> _filepath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/30kr1n.png'; // 3
    return filePath;
  }

  

  void download() async {
    await saveImage('30kr1n.png');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                    HexColor.fromHex("f9e7b1"),
                    HexColor.fromHex("f9e7b1"),
                    HexColor.fromHex("f8b444")
                ],
                tileMode: TileMode.decal, // repeats the gradient over the canvas
              ),
            ),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  SelectAudio.play();
                },
                child: Text("do sound"),
              ),
              TextButton(
                onPressed: download, 
                child: Text("download")
              ),
              Flexible(
                flex: 3,
                child: FutureBuilder(
                  future: points,
                  builder: (BuildContext context, AsyncSnapshot<UserPoint> snapshot){
                    if(snapshot.hasData) {
                      return Column(
                        children: [
                          Text('EXP: ${snapshot.data!.exp}'),
                          Text('Gold: ${snapshot.data!.gold}'),
                          ElevatedButton(
                            child: Text("Add exp and point"),
                            onPressed: () {
                              SQLRepo.userPoints.addExp(50);
                              setState(() {
                                points = widget.getUserPoints();
                              });
                            },
                          ),
                        ],
                      );
                    } else {
                      return Text("Loading");
                    }
                  }
                )
              ),
            ],
          )
        )
      )
    );
  }
}

// class KanjiWidget extends StatelessWidget {

//   final Kanji kanji;

//   const KanjiWidget({Key? key, required this.kanji}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(
//           width: 1
//         )
//       ),
//       child: Column(
//         children: [
//           Text(kanji.id.toString()),
//           Text(kanji.rune),
//           Text(kanji.kunyomi.join("/")),
//           Text(kanji.onyomi.join("/")),
//           Text(kanji.chapter.toString()),
//           Text(kanji.mastery.toString()),
//         ],
//       ),
//     );
//   }
// }