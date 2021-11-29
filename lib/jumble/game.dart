import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';

class JumbleGame extends StatefulWidget {
  JumbleGame({Key? key, required this.mode}) : super(key: key) {
    questionSet = _getQuestionSet();
  }

  QuestionSet? questionSet;
  final GAME_MODE mode;

  QuestionSet _getQuestionSet() {
    Question question = Question(value: '30kr1n.png', isImage: true, key: 'abcdef');
    List<Option> options = [
      Option(id: 1,value: "a", key: "a"),
      Option(id: 2,value: "b", key: "b"),
      Option(id: 3,value: "c", key: "c"),
      Option(id: 4,value: "d", key: "d"),
      Option(id: 5,value: "e", key: "e"),
      Option(id: 6,value: "f", key: "f"),
      Option(id: 7,value: "g", key: "g"),
      Option(id: 8,value: "h", key: "h"),
      Option(id: 9,value: "i", key: "i")
    ];
    var qs = QuestionSet(question: question, options: options);
    return qs;
  }
  @override
  State<StatefulWidget> createState() => _JumbleGameState();
}

class _JumbleGameState extends State<JumbleGame> {

  Widget _questionWidget() {
    
    if(widget.mode == GAME_MODE.imageMeaning) {
      return Container(
        child: Image(
          image: AssetImage(KANJI_IMAGE_FOLDER + widget.questionSet!.question.value),
          fit: BoxFit.cover,  
        ),
        height: 300,
        width: 300
      );
    } else {
      return Container(
        child: Center(
          child: Text(
            widget.questionSet!.question.value,
          ),
        ),
        height: 300,
        width: 300
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          //question
          child: Column(
            children: [
              _questionWidget(),
              SizedBox(height: 35),
              //selected box
              Container(
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: widget.questionSet!.question.key.split('').map((e) {
                       return Container(
                         decoration: BoxDecoration(
                           border: Border.all(
                             width: 1
                           )
                         ),
                         height: 50,
                         width: 50
                       );
                    }).toList(),
                ),
              ),
              SizedBox(height: 35),
              //options
              // Expanded(
                Container(
                  
                  child: GridView.count(
                    crossAxisCount: 5,
                    padding: EdgeInsets.all(50),
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    shrinkWrap: true,
                    children: widget.questionSet!.options.map((opt){
                      //option box
                      return Container(
                        child: Center(
                          child: Text(opt.value),
                        ),
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1
                          )),
                      );
                    }).toList(),
                  ),
                )
              // )
            ],)
        ) 
      )
    );
  }
}