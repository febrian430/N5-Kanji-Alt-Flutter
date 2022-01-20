import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game_components/question_widget.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/foreach_indexed.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/theme.dart';


const SENTINEL = const Option(value: "-1", key: "-1");

class JumbleQuizRound extends StatefulWidget {
  const JumbleQuizRound({Key? key, required this.mode, required this.question, required this.options, required this.onComplete, required this.isOver, required this.onSubmit, required this.index, required this.restartSource}) : super(key: key);

  final int index;
  final JumbleQuestion question;
  final List<Option> options;
  final GAME_MODE mode;
  final bool isOver;
  final bool restartSource;
  final Function(bool isCorrect, int slotsToFill, int misses, bool initial, int index) onComplete;
  final Function(bool isCorrect, int slotsToFill, int misses, int index) onSubmit;

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

  late final int slotsToFill = widget.question.key.length;

  int selectCount = 0;
  int misses = 0;
  List<Option> selected = [];
  bool initial = true;
  bool initialRerender = true;
  
  bool wasRestarted = false;

  void restart() {
    setState(() {
      print("question during restart setState ${widget.index}:${widget.question.key.length}");
      selected = widget.question.key.map((_) => SENTINEL).toList();
      selectCount = 0;
      selected = [];
      misses = 0;
      wasRestarted = true;
    });
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
      if(selected.contains(option)){
        
        var index = selected.indexOf(option);
        _unselect([index]);
        return;
      }

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
            widget.onComplete(true, answerLength, misses, initial, widget.index);
          } else {
            misses += diff.length;
            widget.onComplete(false, answerLength-misses, misses, initial, widget.index);
          }
          initial = false;
        });
      }
    }
  }

  int _firstEmptySlot() {
    return selected.indexOf(SENTINEL);
  }

  Column _optionsByColumn(BuildContext context, List<Option> opts) {

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: opts.take(4).map((opt) {
              return Padding(
                padding: EdgeInsets.all(5),
                child: OptionWidget(
                  option: opt, 
                  selected: selected.contains(opt),
                  disabled: false, 
                  onTap: () { _handleOptionTap(opt); },
                )
              );
            }).toList()
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: opts.skip(4).map((opt) {
              return Padding(
                padding: EdgeInsets.all(5),
                child: OptionWidget(
                  option: opt, 
                  selected: selected.contains(opt),
                  disabled: false, 
                  onTap: () { _handleOptionTap(opt); },
                )
              );
            }).toList()
          ),
        ]
      );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(widget.restartSource) {
        restart();
      }
      if(widget.isOver && initialRerender){
        var diff = _differentIndexes();
        widget.onSubmit(diff.isEmpty, widget.question.key.length, diff.length, widget.index);
        initialRerender = false;
      }
    });

    if(wasRestarted) {
      setState(() {
        selected = widget.question.key.map((_) => SENTINEL).toList();
        wasRestarted = false;
      });
    }

    return Center(
      child: Container(
        // height: MediaQuery.of(context).size.height - 120,
        decoration: BoxDecoration(
          // border: Border.all(
          //   width: 1,
          // ),
        ),
        //question
        child: Column(
          children: [
            Expanded(
              flex: 14,
              child: Container(
                // decoration: BoxDecoration(border: Border.all(width: 1)),
                child: Column(
                children: [
                  Expanded(flex: 14, child: QuestionWidget(mode: widget.mode, questionStr: widget.question.value)),
                  widget.isOver ? 
                  Flexible(
                    flex: 2, 
                    child: Text(
                      widget.question.key.join(" "),
                      style: TextStyle(
                        fontSize: 20,
                        // fontWeight: FontWeight.bold
                      ),
                    )
                  )
                  :
                  EmptyFlex(flex: 1),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: selected.mapIndexed((select, i) {
                          return Container(
                            margin: EdgeInsets.only(left: 4, right: 4),
                            child: _QuizSelectWidget(
                              option: select, 
                              isOver: widget.isOver, 
                              isCorrect: widget.question.key[i] == select.value, 
                              disabled: widget.isOver, 
                              onTap: () { _handleSelectTap(select, i); }
                            )
                          );
                        }).toList(),
                    ),
                  ),
                ]
              )
              )
            ),
            //options
            Flexible(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  // border: Border.all(
                  //   width: 1
                  // )
                ),
                child: _optionsByColumn(context, widget.options)
              )
            )
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

  Widget _drawAfterQuizOver(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    Color bgColor = AppColors.wrong;

    if(isCorrect) {
      bgColor = AppColors.correct;
    }

    return GestureDetector( 
      child: Container(
          height: height*0.06,
          child: AspectRatio(
            aspectRatio: 8/9, 
            child: Container(
              width: width*1,
            decoration: BoxDecoration(
              color: bgColor,
              // border: Border.all(
              //   width: 1,
              // )
            ),
            child: Center(
              child: Text(
                !_isSentinel() ? option.value : "",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              )
            ),
          )
          )
          )
    );
  }

  Widget _drawDuringQuiz(BuildContext context){
    Color bgColor = Colors.white;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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
          height: height*0.06,
          child: AspectRatio(
            aspectRatio: 8/9, 
            child: Container(
              width: width*1,
            decoration: BoxDecoration(
              color: bgColor
            ),
            child: Center(
              child: Text(
                !_isSentinel() ? option.value : ""
              )
            ),
          )
          )
          )
        );
  }

  @override
  Widget build(BuildContext context) {
    if(isOver) {
      return _drawAfterQuizOver(context);
    }
    return _drawDuringQuiz(context);
  }
}