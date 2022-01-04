import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game_components/game_helper.dart';
import 'package:kanji_memory_hint/game_components/question_widget.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/jumble/repo.dart';
import 'package:kanji_memory_hint/menu_screens/game_screen.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/foreach_indexed.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/scoring/practice/jumble.dart';
import 'package:kanji_memory_hint/scoring/model.dart';
import 'package:kanji_memory_hint/theme.dart';


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
  Set<int> solvedIdx = {};

  late int slotsToFill;
  int? numOfQuestions;

  late PracticeScore endScore;
  late GameResult result;
  late PracticeGameReport report;

  var _questionSets;

  @override
  void initState(){
    super.initState();
    _questionSets = widget._getQuestionSet();
  }

  void _handleRoundOver(bool isCorrect, int misses, int index, bool initialAnswer) {
    setState(() {
      if(isCorrect) {
        if(initialAnswer) {
          perfect++;
          print('SOLVED: ${solved}');
        }
        solved++;
        solvedIdx.add(index);
        _slideToNextQuestion(index, solvedIdx);
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

  void _slideToNextQuestion(int fromIndex, Set<int> answered) async {
    Future.delayed(const Duration(milliseconds: 500), () {
      int? next = GameHelper.nearestUnansweredIndex(fromIndex, answered, GameNumOfRounds);
      print("HERE");
      print("YOUR NEXT LINE IS $next");
      if(next != null){
        _pageController.animateToPage(next, duration: const Duration(milliseconds: 200), curve: Curves.linear);
      }
    });
  }


  Widget _buildRound(BuildContext context, int itemIndex, List<JumbleQuestionSet> questionSets) {
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: JumbleRound(
        index: itemIndex,
        question: questionSets[itemIndex].question, 
        options: questionSets[itemIndex].options, 
        mode: widget.mode, 
        // isOver: numOfQuestions == solved,
        onComplete: _handleRoundOver,
        // onSubmit: _onGameSubmit,
      )
    );
  }

  Widget _buildGame(BuildContext context) {
    var resultButton = EmptyWidget;
    
    if(solved == numOfQuestions) {
      resultButton = ResultButton(
        param: ResultParam(score: endScore, result: result, stopwatch: widget.stopwatch),
        visible: numOfQuestions == solved,
      );
    }
    return Column(
      children: [
        Flexible(
          flex: 15,
          child: FutureBuilder(
            future: _questionSets,
            builder: (context, AsyncSnapshot<List<JumbleQuestionSet>> snapshot) {
              if(snapshot.hasData) {
                widget.stopwatch.start();
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
          ), 
        ),
        Flexible(flex: 1, child: resultButton)
      ]
    );
  }

  void onPause() {
    print("jumble pause");
    widget.stopwatch.stop();
  }

  void onRestart() {
    print("jumble restart");
    widget.stopwatch.reset();
  }

  void onContinue() {
    print("jumble continued");
    widget.stopwatch.start();
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      title: JumbleGame.name, 
      japanese: "Jumble in japanese", 
      game: _buildGame(context), 
      onPause: onPause, 
      onRestart: onRestart, 
      onContinue: onContinue
    );
  }
}

const SENTINEL = const Option(value: "-1", key: "-1");

class JumbleRound extends StatefulWidget {
  const JumbleRound({Key? key, required this.mode, required this.question, required this.options, required this.onComplete, required this.index}) : super(key: key);

  final int index;
  final JumbleQuestion question;
  final List<Option> options;
  final GAME_MODE mode;
  final Function(bool isCorrect, int misses, int index, bool initialAnswer) onComplete;

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

  Color roundColor = AppColors.primary;
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
            widget.onComplete(true, 0, widget.index, isFirstTry);
          });
        } else {
          setState(() {
            misses += diff.length;
            roundColor = _wrongColor;
            widget.onComplete(false, diff.length, widget.index, isFirstTry);
          });
          _unselect(diff);
        }
        isFirstTry = false;
        Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              roundColor = AppColors.primary;
            });
        });
      }
    }
  }

  int _firstEmptySlot() {
    return selected.indexOf(SENTINEL);
  }

  Column _optionsByColumn(BuildContext context, List<Option> opts) {

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: opts.take(4).map((opt) {
              return OptionWidget(option: opt, disabled: selected.contains(opt), onTap: () { _handleOptionTap(opt); },);
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: opts.skip(4).map((opt) {
              return OptionWidget(option: opt, disabled: selected.contains(opt), onTap: () { _handleOptionTap(opt); },);
            }).toList(),
          ),
        ]
      );
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
            Expanded(
              flex: 6,
              child: QuestionWidget(mode: widget.mode, questionStr: widget.question.value),
            ),
            SizedBox(height: 10),
            //selected box
            Flexible(
              flex: 2,
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
            Flexible(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1
                  )
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
    Color bgColor = Colors.white;

    if(!_isSentinel()) {
      bgColor = AppColors.primary;
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

  Widget _draw(BuildContext context) {
    Color boxColor = Colors.white;
    Color textColor = Colors.black;

    if(disabled) {
      boxColor = Colors.grey;
      textColor = Colors.grey;
    }

    return TextButton(
      onPressed: () {
        print("round option is");
        print(disabled);
        if(!disabled) {
          onTap();
        }
      },
      child: Center(
        child: Text(
          option.value,
          style: TextStyle(
            color: Colors.black,
            fontSize: 30
          )
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _draw(context);
  }
}