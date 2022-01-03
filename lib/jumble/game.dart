import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game_components/question_widget.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/jumble/repo.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/foreach_indexed.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/scoring/practice/jumble.dart';
import 'package:kanji_memory_hint/scoring/model.dart';


class JumbleGame extends StatefulWidget {
  JumbleGame({Key? key, required this.mode, required this.chapter}) : super(key: key);

  static const route = '/game/jumble';
  static const name = 'Jumble';

  final GAME_MODE mode;
  final int chapter;
  final bool isQuiz = false;
  final Stopwatch stopwatch = Stopwatch();

  Future<List<JumbleQuestionSet>> _getQuestionSet() async {
    return JumbleQuestionMaker.makeQuestionSet(GameNumOfRounds, chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _JumbleGameState();
}

class _JumbleGameState extends State<JumbleGame> {
  final PageController _pageController =  PageController(viewportFraction: 1,);

  int score = 0;
  int wrongCount = 0;
  int solved = 0;
  int perfect = 0;

  late int slotsToFill;
  late int numOfQuestions;

  late PracticeScore endScore;
  late GameResult result;
  late PracticeGameReport report;

  var _questionSets;

  @override
  void initState(){
    super.initState();
    _questionSets = widget._getQuestionSet();
  }

  void _handleRoundOver(bool isCorrect, int misses, bool initialAnswer) {
    setState(() {
      if(isCorrect) {
        if(initialAnswer) {
          perfect++;
          print('SOLVED: ${solved}');
        }
        _slideToNextQuestion();
        solved++;

      } else {
        wrongCount += misses;
      }

      if(solved == numOfQuestions) {
        widget.stopwatch.stop();
        endScore = PracticeScore(perfectRounds: perfect, wrongAttempts: wrongCount);
        result = JumbleScoring.evaluate(endScore, slotsToFill);
        report = PracticeGameReport(
          game: JumbleGame.name,
          chapter: widget.chapter,
          mode: widget.mode,
          gains: result,
          result: endScore
        );

        PracticeQuestHandler.checkForQuests(report);
      }
    });
  }

  // void _onGameSubmit(bool isCorrect, int misses) {
  //   setState(() {
  //     wrongCount += misses;
  //     if(isCorrect) {
  //       score++;
  //     }
  //   });
  // }

  void _slideToNextQuestion() {
    Future.delayed(const Duration(seconds: 1), () {
      int next = _pageController.page!.round() + 1;
      if(next != numOfQuestions) {
        print("here");
        _pageController.animateToPage(next, duration: const Duration(milliseconds: 200), curve: Curves.linear);
      }
    });
  }


  Widget _buildRound(BuildContext context, int itemIndex, List<JumbleQuestionSet> questionSets) {
    var resultButton = EmptyWidget;
    
    if(solved == numOfQuestions) {
      resultButton = ResultButton(
        param: ResultParam(score: endScore, result: result, stopwatch: widget.stopwatch),
        visible: numOfQuestions == solved,
      );
    }



    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Container(
            child: JumbleRound(
              question: questionSets[itemIndex].question, 
              options: questionSets[itemIndex].options, 
              mode: widget.mode, 
              // isOver: numOfQuestions == solved,
              onComplete: _handleRoundOver,
              // onSubmit: _onGameSubmit,
            )
          ),
          resultButton
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.stopwatch.start();
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _questionSets,
          builder: (context, AsyncSnapshot<List<JumbleQuestionSet>> snapshot) {
            if(snapshot.hasData) {
              numOfQuestions = snapshot.data!.length;
              int sum = 0;
              var screen =  PageView.builder(
                controller: _pageController,
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int itemIndex) {
                  sum += snapshot.data![itemIndex].question.key.length;
                  return _buildRound(context, itemIndex, snapshot.data!);
                },
              );
              slotsToFill = sum;
              return screen;
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
  final Function(bool isCorrect, int misses, bool initialAnswer) onComplete;

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

  Color roundColor = Colors.white;
  final Color _correctColor = Colors.green;
  final Color _wrongColor = Colors.red;

  int selectCount = 0;
  int misses = 0;
  List<Option> selected = [];

  bool isFirstTry = true;
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
    if(!isRoundOver){
      int firstEmpty = _firstEmptySlot();
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
            roundColor = _correctColor;
            widget.onComplete(true, 0, isFirstTry);
          });
        } else {
          setState(() {
            misses += diff.length;
            roundColor = _wrongColor;
            widget.onComplete(false, diff.length, isFirstTry);
          });
          _unselect(diff);
        }
        isFirstTry = false;
        Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              roundColor = Colors.white;
            });
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

    return Center(
      child: Container(
        // height: MediaQuery.of(context).size.height - 120,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
          ),
          color: roundColor
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
              print("round option is");

              print(disabled);
              if(!disabled) {
                onTap();
              }
            },
            child: Container(
              child: Center(
                child: Text(
                    option.value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 30,
                      fontFamily: "MS Mincho"
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