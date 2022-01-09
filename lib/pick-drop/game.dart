
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/game_components/question_widget.dart';
import 'package:kanji_memory_hint/images.dart';
import 'package:kanji_memory_hint/menu_screens/game_screen.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/pick-drop/repo.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/scoring/report.dart';
import 'package:kanji_memory_hint/scoring/practice/pick_drop.dart';
import 'package:kanji_memory_hint/theme.dart';

//TODO: wrong count, correct result page, 
class PickDrop extends StatefulWidget {

  PickDrop({Key? key, required this.chapter, required this.mode}) : super(key: key);

  static const route = '/game/pick-drop';
  static const japanese = "Pick and drag in japanese";
  static const name = 'Pick and Drag';

  final int chapter;
  final GAME_MODE mode;
  final Stopwatch stopwatch = Stopwatch();

  Future<List<QuestionSet>> _getQuestionSets() {
    return PickDropQuestionMaker.makeQuestionSet(GameNumOfRounds, chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _PickDropState();
  
}

class _PickDropState extends State<PickDrop> {

  var sets;
  int index = 0;
  int wrongAttempts = 0;
  int perfect = 0;
  int solved = 0;
  bool restart = false;

  late int total;
  late PracticeScore score;
  late GameResult result;
  late PracticeGameReport report;

  @override
  void initState() {
    super.initState();
    sets = widget._getQuestionSets();
  }


  void _handleOnDrop(bool isCorrect, bool isFirstTry) {
    setState(() {
      if (isCorrect) {
        solved++;

        if(isFirstTry) {
          perfect++;
        }

        if (index < total-1) {
          index++;
        } else {
          widget.stopwatch.stop();
          score = PracticeScore(
            perfectRounds: perfect, 
            wrongAttempts: wrongAttempts,
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
          SQLRepo.userPoints.addExp(result.expGained);
        }
      } else {
        wrongAttempts++;
      }
    });
  }

  Widget _buildRound(QuestionSet set) {
    var resultButton = EmptyWidget;

    if(total == solved) {
      resultButton = ResultButton(
        param: ResultParam(
          route: PickDrop.route,
          score: score, 
          result: result, 
          stopwatch: widget.stopwatch,
          chapter: widget.chapter,
          game: PickDrop.name,
          mode: widget.mode
        ),
        visible: total == solved,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Expanded(
            child: PickDropRound(
              question: set.question, 
              options: set.options, 
              onDrop: _handleOnDrop, 
              isLast: index == total-1,
              restartSrc: restart,
            )
          ),
          resultButton
        ]
      )
    );
  }

  Widget _buildGame(BuildContext context) {
    return FutureBuilder(
      future: sets,
      builder: (context, AsyncSnapshot<List<QuestionSet>> snapshot){
        if(snapshot.hasData){
          widget.stopwatch.start();
          total = snapshot.data!.length;
          var set = snapshot.data!.elementAt(index);
          return _buildRound(set);
        } else {
          return LoadingScreen();
        }
      }
    );
  }

  onPause() {
    widget.stopwatch.stop();
  }

  onRestart() {
    setState(() {
      index = 0;
      wrongAttempts = 0;
      perfect = 0;
      solved = 0;
      sets = widget._getQuestionSets();
      restart = true;
    });
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
      game: _buildGame(context), 
      onPause: onPause, 
      onRestart: onRestart, 
      onContinue: onContinue,
      onGuideOpen: onPause,
      guide: GuideDialog(
        game: PickDrop.name,
        description: "Pick and drag the correct answer to the image",
        guideImage: AppImages.guidePickDrop,
        onClose: onContinue,
      ),
    );
  }
}

typedef OnDropCallback = Function(bool isCorrect, bool isFirstTry);

class PickDropRound extends StatefulWidget {
  const PickDropRound({Key? key, required this.question, required this.options, required this.onDrop, required this.isLast, required this.restartSrc}) : super(key: key);

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

  void restart() {
    setState(() {
      isCorrect = false;
      isFirstTry = true;
    });
  }

  Widget _renderOption(BuildContext context, Option opt) {
    final size = MediaQuery.of(context).size;

    final width = size.width*0.175;


    return Draggable<Option>(
      data: opt,
      maxSimultaneousDrags: 1,
      child: Container(
        height: width,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(width: 3),
          color: AppColors.primary
        ),
        child: Center(
          child: Text(
          opt.value + (widget.question.key == opt.key ? " C" : ""),  
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          )
        )
      ),
      feedback: Container(
        height: width,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(width: 3),
          color: AppColors.primary
        ),
        child: Center(
          child: Text(
          opt.value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            decoration: TextDecoration.none
            ),
          )
        )
      ),

      childWhenDragging: SizedBox(
        height: width,
        width: width,
      )
    );
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
                return QuestionWidget(questionStr: widget.question.value, mode: widget.mode);
              },
              onWillAccept: (opt) {
              //  return opt?.key == widget.question.key;
                return true;
              },
              onAccept: (opt) {
                bool isCorrect = opt.key == widget.question.key;
                widget.onDrop(isCorrect, isFirstTry);
                if(!isCorrect) {
                  isFirstTry = false;
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

class _QuestionWidget extends StatelessWidget {
  const _QuestionWidget({Key? key, required this.value, required this.isImage, required this.answerKey}) : super(key: key);
  
  final String value;
  final bool isImage;
  final String answerKey;

  @override
  Widget build(BuildContext context) {
    if(isImage) {
      return Container(
          child: Image(
            image: AssetImage(KANJI_IMAGE_FOLDER + value),
            height: 250,
            width: 250,
            fit: BoxFit.fill,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
              color: Colors.black
            )
          ),
        );
    } else {
      return Container(
        child: Center(child: Text(value)),
        height: 250,
        width: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 3
          )
        ),
      );
    }
  }
}

class _OptionWidget extends StatelessWidget {
  const _OptionWidget({Key? key, required this.value, required this.answerKey}) : super(key: key);

  final String value;
  final int answerKey;

   @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
          child: Text(
            value,
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            )),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 3
          )
        ),
      );
  }
}