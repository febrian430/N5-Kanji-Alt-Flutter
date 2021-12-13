import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/components/submit_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game_components/question_widget.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/jumble/quiz_round.dart';
import 'package:kanji_memory_hint/jumble/repo.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/foreach_indexed.dart';
import 'package:kanji_memory_hint/route_param.dart';


class JumbleGame extends StatefulWidget {
  const JumbleGame({Key? key, required this.mode, required this.chapter}) : super(key: key);

  static const route = '/game/jumble';
  static const name = 'Jumble';

  final GAME_MODE mode;
  final int chapter;
  final bool isQuiz = false;

  Future<List<JumbleQuestionSet>> _getQuestionSet() async {
    return jumbleQuestionSets(2, chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _JumbleGameState();
}

class _JumbleGameState extends State<JumbleGame> {
  int score = 0;
  int wrongCount = 0;
  int solved = 0;
  
  late int numOfQuestions;
  var _questionSets;

  @override
  void initState(){
    super.initState();
    _questionSets = widget._getQuestionSet();
  }

  void _handleRoundOver(bool isCorrect, int misses, bool initialAnswer) {
    setState(() {
      // if(isCorrect) {
      //   wrongCount += misses;
      // }
      if(initialAnswer) {
        solved++;
      }
    });
  }

  void _onGameSubmit(bool isCorrect, int misses) {
    setState(() {
      wrongCount += misses;
      if(isCorrect) {
        score++;
      }
    });
  }


  Widget _buildRound(BuildContext context, int itemIndex, List<JumbleQuestionSet> questionSets) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Container(
            child: JumbleQuizRound(
              question: questionSets[itemIndex].question, 
              options: questionSets[itemIndex].options, 
              mode: widget.mode, 
              isOver: numOfQuestions == solved,
              onComplete: _handleRoundOver,
              onSubmit: _onGameSubmit,
            )
          ),
          ResultButton(
            param: ResultParam(wrongCount: wrongCount, decreaseFactor: 10),
            visible: numOfQuestions == solved,
          ),
          SubmitButton(visible: widget.isQuiz && numOfQuestions == solved, onTap: () {
            setState(() {
              
            });
          })
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _questionSets,
          builder: (context, AsyncSnapshot<List<JumbleQuestionSet>> snapshot) {
            if(snapshot.hasData) {
              numOfQuestions = snapshot.data!.length;
              return PageView.builder(
                // store this controller in a State to save the carousel scroll position
                controller: PageController(
                  viewportFraction: 1,
                ),
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int itemIndex) {
                  return _buildRound(context, itemIndex, snapshot.data!);
                },
              );
            } else {
              return LoadingScreen();
            }
          }
        )
      )
    );
  }
}

const SENTINEL = const Option(value: "-1", key: "-1");

class JumbleRound extends StatefulWidget {
  const JumbleRound({Key? key, required this.mode, required this.question, required this.options, required this.onComplete}) : super(key: key);

  final JumbleQuestion question;
  final List<Option> options;
  final GAME_MODE mode;
  final Function(int wrong) onComplete;

  @override
  State<StatefulWidget> createState() => _JumbleRoundState(answerLength: question.key.length);
}

class _JumbleRoundState extends State<JumbleRound> with AutomaticKeepAliveClientMixin<JumbleRound> {
  @override
  bool get wantKeepAlive => true;
  
  _JumbleRoundState({required this.answerLength}) {
    for (int i = 0; i < answerLength; i++) {
        selected.add(SENTINEL);
    }
  }
  final int answerLength;

  int selectCount = 0;
  int misses = 0;
  List<Option> selected = [];
  bool isRoundOver = false;

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
    if(!isRoundOver){
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
      if(diff.length == 0) {
        setState(() {
          isRoundOver = true;
          widget.onComplete(misses);
        });
        
      } else {
        _unselect(diff);
        setState(() {
          misses += diff.length;
        });
        diff.forEach((element) {
          print(widget.question.key[element]);
        });
      }
    }
  }

  int _firstEmptySlot() {
    return selected.indexOf(SENTINEL);
  }

  @override
  Widget build(BuildContext context) {
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
                    return SelectWidget(option: select, isRoundOver: isRoundOver, onTap: () { _handleSelectTap(select, i); },);
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