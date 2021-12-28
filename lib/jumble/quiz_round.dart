import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game_components/question_widget.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/foreach_indexed.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


const SENTINEL = const Option(value: "-1", key: "-1");

class JumbleQuizRound extends StatefulWidget {
  const JumbleQuizRound({Key? key, required this.mode, required this.question, required this.options, required this.onComplete, required this.isOver, required this.onSubmit}) : super(key: key);

  final JumbleQuestion question;
  final List<Option> options;
  final GAME_MODE mode;
  final bool isOver;
  final Function(bool isCorrect, int misses, bool initial) onComplete;
  final Function(bool isCorrect, int misses) onSubmit;

  @override
  State<StatefulWidget> createState() => _JumbleQuizRoundState(answerLength: question.key.length);
}

class _JumbleQuizRoundState extends State<JumbleQuizRound> with AutomaticKeepAliveClientMixin<JumbleQuizRound> {
  @override
  bool get wantKeepAlive => true;
  
  _JumbleQuizRoundState({required this.answerLength}) {
    for (int i = 0; i < answerLength; i++) {
        selected.add(SENTINEL);
    }
  }
  final int answerLength;

  int selectCount = 0;
  int misses = 0;
  List<Option> selected = [];
  bool initial = true;
  bool initialRerender = true;

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
    if(!widget.isOver){
      _unselect([index]);
    }
  }

  List<int> _differentIndexes() {
    List<int> diff = [];

    selected.forEachIndexed((select, i) {
      if(select.value != widget.question.key[i]){
        diff.add(i);
      }
    });
    return diff;
  }

  void _handleOptionTap(Option option) {
    if(!widget.isOver){
      int firstEmpty = _firstEmptySlot();
        print(firstEmpty);
        if(firstEmpty != -1){
          setState(() {
            selected[firstEmpty] = option;
            selectCount++;
          });
        }

      if(selectCount == answerLength) {
        var diff = _differentIndexes();
        setState(() {
          if(diff.isEmpty) {
            widget.onComplete(true, misses, initial);
          } else {
            misses += diff.length;
            widget.onComplete(false, misses, initial);
          }
          initial = false;
        });
      }
    }
  }

  int _firstEmptySlot() {
    return selected.indexOf(SENTINEL);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(widget.isOver && initialRerender){
        var diff = _differentIndexes();
        widget.onSubmit(diff.isEmpty, diff.length);
        initialRerender = false;
      }
    });

    

    return Center(
      child: Container(
        // height: MediaQuery.of(context).size.height - 120,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
          ),
        ),
        //question
        child: Column(
          children: [
            QuestionWidget(mode: widget.mode, questionStr: widget.question.value),
            SizedBox(height: 10),
            //selected box
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: selected.mapIndexed((select, i) {
                    return _QuizSelectWidget(
                      option: select, 
                      isOver: widget.isOver, 
                      isCorrect: widget.question.key[i] == select.value, 
                      disabled: widget.isOver, 
                      onTap: () { _handleSelectTap(select, i); });
                  }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            //options
            // Expanded(
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1
                )
              ),
              child: GridView.count(
                crossAxisCount: 4,
                padding: EdgeInsets.all(25),
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                shrinkWrap: true,
                children: widget.options.map((opt){
                  //option box
                  return OptionWidget(option: opt, disabled: selected.contains(opt), onTap: () { _handleOptionTap(opt); },);
                }).toList(),
              ),
            )
            // )
          ],
        )
      )
    );
  }
}

class _QuizSelectWidget extends StatelessWidget {

  final Option option;
  final bool disabled;
  final bool isOver;
  final bool isCorrect;
  final Function() onTap;

  const _QuizSelectWidget({Key? key, required this.option, required this.disabled, required this.isOver, required this.onTap, required this.isCorrect }) : super(key: key);

  bool _isSentinel() {
    return option.id == SENTINEL.id;
  }

  Widget _drawAfterQuizOver() {
    Color bgColor = Colors.red;

    if(isCorrect) {
      bgColor = Colors.green;
    }

    return GestureDetector( 
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

  Widget _drawDuringQuiz(){
    Color bgColor = Colors.grey;

    if(!_isSentinel()) {
      bgColor = Colors.white;
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
    if(isOver) {
      return _drawAfterQuizOver();
    }
    return _drawDuringQuiz();
  }
}