import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';

class QuestionWidget extends StatelessWidget {
  
  final GAME_MODE mode;
  final String questionStr;

  const QuestionWidget({Key? key, required this.mode, required this.questionStr}) : super(key: key);
  
  Widget _getQuestionWidget() {
    if(mode == GAME_MODE.imageMeaning) {
      return Image(
        image: AssetImage(KANJI_IMAGE_FOLDER + questionStr),
        height: 100,
        width: 100,
        fit: BoxFit.fill,
      );
    } else {
      return Center(
        child: Text(
          questionStr,
          style: TextStyle(
            fontSize: 60
          ),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width*0.8,
      width: MediaQuery.of(context).size.width*0.8,
      child: Container(
        child: _getQuestionWidget(),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 3
          )
        ),
      )
    );
    
  }
}