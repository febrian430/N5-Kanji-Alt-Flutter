import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/foreach_indexed.dart';



const SENTINEL = const Option(value: "-1", key: "-1");

class JumbleGame extends StatefulWidget {
  JumbleGame({Key? key, required this.mode}) : super(key: key) {
    questionSet = _getQuestionSet();
  }

  late QuestionSet questionSet;
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
  State<StatefulWidget> createState() => _JumbleGameState(question: questionSet.question, options: questionSet.options);
}

class _JumbleGameState extends State<JumbleGame> {
  _JumbleGameState({required this.question, required this.options}) {
    question.key.split("").forEach((_) => {
      selected.add(SENTINEL)
    });
    answerLength = question.key.length;
  }

  final Question question;
  final List<Option> options;
  late final int answerLength;

  int selectCount = 0;
  int wrongAttempts = 0;
  List<Option> selected = [];
  bool isRoundOver = false;

  Widget _questionWidget() {
    
    if(widget.mode == GAME_MODE.imageMeaning) {
      return Container(
        child: Image(
          image: AssetImage(KANJI_IMAGE_FOLDER + question.value),
          fit: BoxFit.cover,  
          ),
          height: 300,
          width: 300
      );
    } else {
      return Container(
        child: Center(
          child: Text(
          question.value,
          ),
        ),
        height: 300,
        width: 300
      );
    }
  }

  void _unselect(List<int> indexes) {
    indexes.forEach((index) {
      selected[index] = SENTINEL;
    });

    setState(() {
      selected = [...selected];
      selectCount -= indexes.length;
    });
  }

  void _handleSelectTap(Option option, int index) {
    _unselect([index]);
  }

  List<int> _differentIndexes() {
    List<int> diff = [];

    selected.forEachIndexed((select, i) {
      if(select.value != question.key[i]){
        diff.add(i);
      }
    });
    return diff;
  }

  void _handleOptionTap(Option option) {
    setState(() {
      int firstEmpty = _firstEmptySlot();
      if(firstEmpty != -1){
        selected[firstEmpty] = option;
        selectCount++;
      }
    });
    if(selectCount == answerLength) {
      var diff = _differentIndexes();
      if(diff.length == 0) {
        setState(() {
          isRoundOver = true;
        });
      }else {
        _unselect(diff);
        setState(() {
          wrongAttempts++;
        });
      }
    }
  }

  int _firstEmptySlot() {
    return selected.indexOf(SENTINEL);
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
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   mainAxisSize: MainAxisSize.min,
                   children: selected.mapIndexed((select, i) {
                       return SelectWidget(option: select, isRoundOver: isRoundOver, onTap: () { _handleSelectTap(select, i); },);
                    }).toList(),
                ),
              ),
              const SizedBox(height: 35),
              //options
              // Expanded(
                Container(
                  child: GridView.count(
                    crossAxisCount: 5,
                    padding: EdgeInsets.all(50),
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    shrinkWrap: true,
                    children: options.map((opt){
                      //option box
                      return OptionWidget(option: opt, disabled: selected.contains(opt), onTap: () { _handleOptionTap(opt); },);
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

typedef OnTapFunc = Function();

class SelectWidget extends StatelessWidget {
  const SelectWidget({Key? key, required this.option, required this.isRoundOver, required this.onTap}): super(key: key);

  final Option option;
  final bool isRoundOver;
  final OnTapFunc onTap;

  bool _isSentinel() {
    return option.id == SENTINEL.id;
  }

  Widget _draw(){
    Color bgColor = Colors.grey;

    if(!_isSentinel()) {
      bgColor = Colors.white;
    } 
    if(isRoundOver) {
      bgColor = Colors.green;
    }

    return GestureDetector( 
            onTap: () { 
              if(!_isSentinel()){
                onTap();
              }
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: bgColor
              ),
              child: Center(
                child: Text(
                  !_isSentinel() ? option.value : ""
                )
              ),
            )
          );
  }

  @override
  Widget build(BuildContext context) {
    return _draw();
  }
}

class OptionWidget extends StatelessWidget {
  const OptionWidget({Key? key, required this.option, this.disabled = false, required this.onTap }) : super(key: key);
  
  final Option option;
  final bool disabled;
  final OnTapFunc onTap;

  Widget _draw() {
    Color boxColor = Colors.white;
    Color textColor = Colors.black;

    if(disabled) {
      boxColor = Colors.grey;
      textColor = Colors.grey;
    }

    return GestureDetector(
            onTap: () {
              if(!disabled) {
                onTap();
              }
            },
            child: Container(
              child: Center(
                child: Text(
                    option.value,
                    style: TextStyle(
                      color: textColor
                    ),
                  ),
              ),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1
                ),
                color: boxColor
              ),
            )
          );
  }

  @override
  Widget build(BuildContext context) {
    return _draw();
  }
}