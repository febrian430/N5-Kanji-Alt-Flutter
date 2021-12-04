import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/main.dart';
import 'package:kanji_memory_hint/route_param.dart';

class ResultScreen extends StatelessWidget{
  // ResultScreen({required this.wrongCount, required this.decreaseFactor}){
  //   points = 1000 - decreaseFactor*wrongCount;
  // }

  ResultScreen({Key? key}) : super(key: key);

  static const route = "/result";
  
  // final int wrongCount = 0;
  // final int decreaseFactor = 0;
  // late int points = 0;

  @override
  Widget build(BuildContext context) {
    var param = ModalRoute.of(context)!.settings.arguments as ResultParam;
    var points = 1000 - param.decreaseFactor*param.wrongCount;
    print(param.wrongCount);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Wrong attempts"),
                    Text(param.wrongCount.toString()),
                    SizedBox(height: 100,),
                    Text("Points gained"),
                    Text(points.toString())
                ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    TextButton(
                      onPressed: () {
                        // Navigator.of(context).pushAndRemoveUntil(
                        //   MaterialPageRoute(
                        //     builder: (context) => Home()
                        //   ),
                        //   (route) => false
                        // );
                        Navigator.of(context).popUntil(ModalRoute.withName("/"));
                      },
                      child: Center(
                        child: Text(
                          "Main Screen"
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).popUntil(ModalRoute.withName("/game"));
                      },
                      child: Center(
                        child: Text(
                          "Practice"
                        ),
                      ),
                    ),
                  ]
                )
              ],
            )
          )
        )
      )
    );
  }
}