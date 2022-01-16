import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/theme.dart';

class QuestionWidget extends StatelessWidget {
  
  final GAME_MODE mode;
  final String questionStr;
  bool overlay;
  bool withShadow;
  bool correctBorder;

  QuestionWidget({
    Key? key, 
    required this.mode, 
    required this.questionStr,
    this.overlay = false,
    this.withShadow = false,
    this.correctBorder = false
  }) : super(key: key);
  
  Widget _getQuestionWidget() {
    if(mode == GAME_MODE.imageMeaning) {
      double opacity = overlay ? .6 : 1;
      Widget image = Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.wrong,
          image: DecorationImage(
            
            image: AssetImage(KANJI_IMAGE_FOLDER + questionStr),
            fit: BoxFit.fill,

            colorFilter: ColorFilter.mode(Colors.red.withOpacity(opacity), BlendMode.dstATop)
          )
        ),
      );

      return image;
      
      // return Image(
      //   colorBlendMode: BlendMode.color,
      //   image: AssetImage(KANJI_IMAGE_FOLDER + questionStr),
      //   height: 100,
      //   width: 100,
      //   fit: BoxFit.fill, 
      // );
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
    return AspectRatio(
        aspectRatio: 1,
        child: Container(
          child: _getQuestionWidget(),
          decoration: BoxDecoration(
            border: Border.all(
              color: correctBorder ? AppColors.correct: Colors.black,
              width: correctBorder ? 5 : 3,
            ),
            color: AppColors.primary
          ),
        )

    );
    
  }
}