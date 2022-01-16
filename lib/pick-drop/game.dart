
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game_components/question_widget.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/images.dart';
import 'package:kanji_memory_hint/levelling/levels.dart';
import 'package:kanji_memory_hint/menu_screens/game_screen.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/pick-drop/repo.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/scoring/report.dart';
import 'package:kanji_memory_hint/scoring/practice/pick_drop.dart';
import 'package:kanji_memory_hint/theme.dart';

class PickDrop extends StatefulWidget {

  PickDrop({Key? key, required this.chapter, required this.mode, this.prevQuestions}) : super(key: key);

  static const route = '/game/pick-drop';
  static const japanese = "ピックドラッグ";
  static const name = 'Pick and Drag';

  final int chapter;
  final GAME_MODE mode;
  final Stopwatch stopwatch = Stopwatch();
  final List<QuestionSet>? prevQuestions;

  Future<List<QuestionSet>> _getQuestionSets() {
    return PickDropQuestionMaker.makeQuestionSet(GameNumOfRounds, chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _PickDropState();
  
}

class _PickDropState extends State<PickDrop> {

  List<QuestionSet> restartQuestions = [];

  var sets;
  int index = 0;
  int wrongAttempts = 0;
  int perfect = 0;
  int solved = 0;
  bool restart = false;

  List<int> attempts = [];

  late int total = GameNumOfRounds;
  late PracticeScore score;
  late GameResult result;
  late PracticeGameReport report;

  @override
  void initState() {
    super.initState();
    sets = widget._getQuestionSets();
  }

  void onRestartFromResult() {
    var arg = PracticeGameArguments(
      selectedGame: PickDrop.route,
      gameType: GAME_TYPE.PRACTICE
    );
    arg.chapter = widget.chapter;
    arg.mode = widget.mode;

    if(restartQuestions.isEmpty) {
      arg.pickDropRestart = widget.prevQuestions;
    } else {
      arg.pickDropRestart = restartQuestions;
    }
    
    Navigator.of(context).popAndPushNamed(
      PickDrop.route, 
      arguments: arg, 
      result: true
    );
  }

  void _handleOnDrop(bool isCorrect, int roundAttempts) {
    setState(() {
      if (isCorrect) {
        solved++;

        if(roundAttempts == 0) {
          perfect++;
        }

        wrongAttempts += roundAttempts;
        attempts.add(roundAttempts);

        if (index < total-1) {
          index++;
        } else {
          widget.stopwatch.stop();
          score = PracticeScore(
            perfectRounds: perfect, 
            wrongAttempts: wrongAttempts,
            attemptsPerRound: attempts,
            chapter: widget.chapter,
            mode: widget.mode
          );
          result = PickDropScoring.evaluate(score);
          
          report = PracticeGameReport(
            game: PickDrop.name,
            chapter: widget.chapter,
            mode: widget.mode,
            gains: result,
            result: score
          );

          PracticeQuestHandler.checkForQuests(report);
          Levels.addExp(result.expGained);
        }
      }
    });
  }

  Widget _buildRound(BuildContext context, List<QuestionSet> sets) {
    var resultButton = EmptyWidget;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: IndexedStack(
        index: index,
        children: sets.map((set) {
          return PickDropRound(
            question: set.question,   
            options: set.options, 
            onDrop: _handleOnDrop, 
            isLast: index == total-1,
            restartSrc: restart,
          );
        }).toList()
      )
    );
  }

  Widget _buildGame(BuildContext context) {
    var fromPrev = widget.prevQuestions;

    if(fromPrev == null) {
      return FutureBuilder(
        future: sets,
        builder: (context, AsyncSnapshot<List<QuestionSet>> snapshot){
          if(snapshot.hasData){
            if(restartQuestions.isEmpty) {
              restartQuestions = snapshot.data!;
            }
            widget.stopwatch.start();
            total = snapshot.data!.length;
            return _buildRound(context, snapshot.data!);
          } else {
            return LoadingScreen();
          }
        }
      );
    } else {
      widget.stopwatch.start();
      total = fromPrev.length;
      return _buildRound(context, fromPrev);
    }
  }

  onPause() {
    widget.stopwatch.stop();
  }

  onContinue() {
    widget.stopwatch.start();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(restart) {
        setState(() {
          restart = false;
        });
      }
    });

    return GameScreen(
      title: PickDrop.name, 
      japanese: PickDrop.japanese, 
      icon: AppIcons.pickdrop,
      isGameOver: total == solved,
      game: _buildGame(context), 
      onPause: onPause, 
      onRestart: onRestartFromResult, 
      onContinue: onContinue,
      onGuideOpen: onPause,
      prevVisible: index != 0,
      nextVisible: index != (total-1),
      onNext: (){
        setState(() {
          index++;
        });
      },
      onPrev: (){
        setState(() {
          index--;
        });
      },
      footer: total == solved ? ResultButton(
        param: ResultParam(
          onRestart: onRestartFromResult,
          route: PickDrop.route,
          score: score, 
          result: result, 
          stopwatch: widget.stopwatch,
          chapter: widget.chapter,
          game: PickDrop.name,
          mode: widget.mode
        ),
        visible: total == solved,
      ) : SizedBox()
    ,
      guide: GuideDialog(
        game: PickDrop.name,
        description: "Pick and drag the correct answer to the image",
        guideImage: AppImages.guidePickDrop,
        onClose: onContinue,
      ),
    );
  }
}

typedef OnDropCallback = Function(bool isCorrect, int attempts);

class PickDropRound extends StatefulWidget {
  const PickDropRound({
    Key? key, 
    required this.question, 
    required this.options, 
    required this.onDrop, 
    required this.isLast, 
    required this.restartSrc
  }) : super(key: key);

  final Question question;
  final List<Option> options;
  final OnDropCallback onDrop;
  final GAME_MODE mode = GAME_MODE.imageMeaning;
  final bool isLast;
  final bool restartSrc;

  @override
  State<StatefulWidget> createState() => _PickDropRoundState();
}

class _PickDropRoundState extends State<PickDropRound> {

  bool isCorrect = false;
  bool isFirstTry = true;
  bool isSolved = false;

  bool wrongOverlay = false;
  bool correctOverlay = false;

  int attempts = 0;

  void restart() {
    setState(() {
      isCorrect = false;
      isFirstTry = true;
    });
  }

  Widget _renderOption(BuildContext context, Option opt) {
    final size = MediaQuery.of(context).size;

    final width = size.width*0.175;
    final revealAnswer = isSolved && widget.question.key == opt.key;

    if(!isSolved) {
      return Draggable<Option>(
        data: opt,
        maxSimultaneousDrags: 1,
        child: _OptionWidget(
          option: opt, 
          answerKey: widget.question.key,
          reveal: revealAnswer,
        ),
        feedback: _OptionWidget(
          option: opt, 
          answerKey: widget.question.key, 
          reveal: revealAnswer
        ),

        childWhenDragging: SizedBox(
          height: width,
          width: width,
        )
      );
    } else {
      return _OptionWidget(
        option: opt, 
        answerKey: widget.question.key, 
        reveal: revealAnswer
      );
    }
  }

  Column _optionsByColumn(BuildContext context, List<Option> opts) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: opts.take(4).map((opt) {
            return _renderOption(context, opt);
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: opts.skip(4).map((opt) {
            return _renderOption(context, opt);
          }).toList(),
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(widget.restartSrc) {
        restart();
      }
    });

    return Center(
      child: Column(  
        children: [
          Flexible(
            flex: 5,
            child: DragTarget<Option>(
              builder: (context, candidateData, rejectedData) {
                return QuestionWidget(
                  questionStr: widget.question.value, 
                  mode: widget.mode,
                  overlay: wrongOverlay,
                  correctBorder: correctOverlay,
                );
              },
              onWillAccept: (opt) {
              //  return opt?.key == widget.question.key;
                return true;
              },
              onAccept: (opt) async {
                if(!isSolved){
                  bool isCorrect = opt.key == widget.question.key;
                  bool tempFirstTry = isFirstTry;
                  if(!isCorrect) {
                    isFirstTry = false;
                    attempts++;
                    setState(() {
                      wrongOverlay = true;
                    });
                    Future.delayed(const Duration(milliseconds: 300), (){
                      setState(() {
                        wrongOverlay = false;
                      });
                    });
                  } else {
                    setState(() {
                      isSolved = true;
                      correctOverlay = true;
                    });
                    await Future.delayed(const Duration(milliseconds: 300), (){
                      setState(() {
                        correctOverlay = false;
                      });
                    });
                  }

                  widget.onDrop(isCorrect, attempts);

                }
              },
            ),
          ),
          SizedBox(height: size.height*0.05,),
          Flexible(
            flex: 3,
            child: SizedBox(
              child: _optionsByColumn(context, widget.options),
              height: size.height*0.25,
            )
          ),
        ],
      )
    );
  }
}

class _OptionWidget extends StatelessWidget {
  const _OptionWidget({Key? key, required this.option, required this.answerKey, required this.reveal}) : super(key: key);

  final Option option;
  final String answerKey;
  final bool reveal;

   @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width*0.175;

    return Container(
        child: Center(
          child: Text(
            option.value + (answerKey == option.key ? " C" : ""),
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                decoration: TextDecoration.none
            ),
          )
        ),
        height: width+15,
        width: width+20,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 3
          ),
          color: reveal ? AppColors.correct : AppColors.primary
        ),
      );
  }
}