import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/menu_screens/result_screen.dart';
import 'package:kanji_memory_hint/route_param.dart';

class ResultButton extends StatelessWidget  {
  const ResultButton({Key? key, required this.visible, required this.param}) : super(key: key);
  
  final bool visible;
  final ResultParam param;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: visible,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, ResultScreen.route, 
              arguments: ResultParam(wrongCount: param.wrongCount, decreaseFactor: param.decreaseFactor));
          }, 
          child: const Center(
            child: Text(
              'See result'
            )
          )
        )
      );
  }
}