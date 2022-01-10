import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game_components/game_helper.dart';
import 'package:kanji_memory_hint/game_components/question_widget.dart';
import 'package:kanji_memory_hint/images.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/jumble/repo.dart';
import 'package:kanji_memory_hint/menu_screens/game_screen.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/foreach_indexed.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/scoring/practice/jumble.dart';
import 'package:kanji_memory_hint/scoring/report.dart';
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
    print("Question fetch");
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
  List<int> perfectRoundsSlots = [];

  late int slotsToFill;
  int? numOfQuestions;

  bool restart = false;

  late PracticeScore endScore;
  late GameResult result;
  late PracticeGameReport report;

  var _questionSets;

  @override
  void initState(){
    super.initState();
    _questionSets = widget._getQuestionSet();
  }

  void onPause() {
    widget.stopwatch.stop();
  }

  void onRestart() {
    setState(() {
      score = 0;
      wrongCount = 0;
      solved = 0;
      perfect = 0;
      solvedIdx = {};
      slotsToFill = 0;
      numOfQuestions = null;
      _questionSets =  widget._getQuestionSet();
      restart = true;
    });
  }

  void onContinue() {
    widget.stopwatch.start();
  }

  void onRestartFromResult() {
    var arg = PracticeGameArguments(
      selectedGame: JumbleGame.route,
      gameType: GAME_TYPE.PRACTICE
    );
    arg.chapter = widget.chapter;
    arg.mode = widget.mode;
    
    Navigator.of(context).pop(true);

    Navigator.of(context).popAndPushNamed(
      JumbleGame.route, 
      arguments: arg
    );
  }

  void _handleRoundOver(bool isCorrect, int misses, int index, int slotsToFill, bool initialAnswer) {
    setState(() {
      if(isCorrect) {
        if(initialAnswer) {
          perfect++;
          perfectRoundsSlots.add(slotsToFill);
        }
        solved++;
        solvedIdx.add(index);
        _slideToNextQuestion(index, solvedIdx);
      } else {
        wrongCount += misses;
      }

      if(solved == numOfQuestions) {
        widget.stopwatch.stop();
        endScore = PracticeScore(
          perfectRounds: perfect, 
          wrongAttempts: wrongCount,
          chapter: widget.chapter,
          mode: widget.mode
        );
        result = JumbleScoring.evaluate(endScore, slotsToFill, perfectRoundsSlots);
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

  void _slideToNextQuestion(int fromIndex, Set<int> answered) async {
    Future.delayed(const Duration(milliseconds: 500), () {
      int? next = GameHelper.nearestUnansweredIndex(fromIndex, answered, GameNumOfRounds);
      if(next != null){
        _pageController.animateToPage(next, duration: const Duration(milliseconds: 200), curve: Curves.linear);
      }
    });
  }


  Widget _buildRound(BuildContext context, int itemIndex, List<JumbleQuestionSet> questionSets) {
    print("building round at index $itemIndex: ${questionSets[itemIndex].question.key.length}");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: JumbleRound(
        index: itemIndex,
        question: questionSets[itemIndex].question, 
        options: questionSets[itemIndex].options, 
        mode: widget.mode, 
        // isOver: numOfQuestions == solved,
        onComplete: _handleRoundOver,
        restartSource: restart,
        // onSubmit: _onGameSubmit,
      )
    );
  }

  Widget _buildGame(BuildContext context) {
    var resultButton = EmptyWidget;
    
    if(solved == numOfQuestions) {
      resultButton = ResultButton(
        param: ResultParam(
          onRestart: onRestartFromResult,
          route: JumbleGame.route,
          score: endScore, 
          result: result, 
          stopwatch: widget.stopwatch,
          chapter: widget.chapter,
          game: JumbleGame.name,
          mode: widget.mode
        ),
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

  @override
  Widget build(BuildContext context) {
    print("restart is $restart");

    WidgetsBinding.instance?.addPostFrameCallback((_){
      if(restart){
        setState(() {
          restart = false;
        });
      }
    });


    return GameScreen(
      title: JumbleGame.name, 
      japanese: "ごちゃ混ぜ", 
      game: _buildGame(context), 
      onPause: onPause, 
      onRestart: onRestart, 
      onContinue: onContinue,
      onGuideOpen: onPause,
      guide: GuideDialog(
        game: JumbleGame.name,
        description: "Select the correct hiragana in the correct order",
        guideImage: AppImages.guideJumble,
        onClose: onContinue,
      ),
    );
  }
}

const SENTINEL = const Option(value: "-1", key: "-1");

class JumbleRound extends StatefulWidget {
  const JumbleRound({Key? key, required this.mode, required this.question, required this.options, required this.onComplete, required this.index, required this.restartSource}) : super(key: key);

  final int index;
  final JumbleQuestion question;
  final List<Option> options;
  final GAME_MODE mode;
  final bool restartSource;
  final Function(bool isCorrect, int misses, int index, int slotsToFill, bool initialAnswer) onComplete;

  @override
  State<StatefulWidget> createState() => _JumbleRoundState();
}

class _JumbleRoundState extends State<JumbleRound> with AutomaticKeepAliveClientMixin<JumbleRound> {
  @override
  bool get wantKeepAlive => true;


  _JumbleRoundState();

  Color roundColor = Colors.transparent;
  final Color _correctColor = Colors.green;
  final Color _wrongColor = Colors.red;

  int selectCount = 0;
  int misses = 0;
  List<Option> selected = [];

  bool isFirstTry = true;
  bool isRoundOver = false;
  bool wasRestarted = false;


  @override
  void initState() {
    super.initState();

    selected = widget.question.key.map((_) => SENTINEL).toList();
  }

  void restart() {
    setState(() {
      print("question during restart setState ${widget.index}:${widget.question.key.length}");
      selected = widget.question.key.map((_) => SENTINEL).toList();
      roundColor = AppColors.primary;
      selectCount = 0;
      misses = 0;
      isFirstTry = true;
      isRoundOver = false;
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

      if(selectCount == widget.question.key.length) {
        var diff = _differentIndexes();
        if(diff.length == 0) {
          setState(() {
            isRoundOver = true;
            roundColor = _correctColor;
            widget.onComplete(true, 0, widget.index, widget.question.key.length, isFirstTry);
          });
        } else {
          setState(() {
            misses += diff.length;
            roundColor = _wrongColor;
            widget.onComplete(false, diff.length, widget.index, widget.question.key.length, isFirstTry);
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
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(widget.restartSource) {
        restart();
      }
    });
    if(wasRestarted) {
      setState(() {
         selected = widget.question.key.map((_) => SENTINEL).toList();
         wasRestarted = false;
      });
    }

    print("question  ${widget.index}: ${widget.question.key.length}");


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
            Flexible(
              flex:7,
              child: QuestionWidget(mode: widget.mode, questionStr: widget.question.value),
            ),
            Text(widget.question.key.join('')),

            //selected box
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: selected.mapIndexed((select, i) {
                    return Container(
                      margin: EdgeInsets.only(left: 4, right: 4),
                      child: SelectWidget(option: select, isRoundOver: isRoundOver, onTap: () { _handleSelectTap(select, i); },)
                    );
                  }).toList(),
              ),
            ),

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

  Widget _draw(BuildContext context){
    Color bgColor = Colors.white;

    if(!_isSentinel()) {
      bgColor = AppColors.primary;
    } 
    if(isRoundOver) {
      bgColor = Colors.green;
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
                color: bgColor,
                border: Border.all(
                  width: 1,
                  color: Colors.grey
                )
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
    return _draw(context);
  }
}

class OptionWidget extends StatelessWidget {
  const OptionWidget({Key? key, required this.option, this.disabled = false, required this.onTap }) : super(key: key);
  
  final Option option;
  final bool disabled;
  final OnTapFunc onTap;

  Widget _draw(BuildContext context) {
    Color boxColor = AppColors.primary;
    Color textColor = Colors.black;

    if(disabled) {
      boxColor = AppColors.selected;
      textColor = AppColors.selected;
    }

    return TextButton(
      onPressed: () {
        if(!disabled) {
          onTap();
        }
      },
      child: Center(
        child: Text(
          option.value,
          style: TextStyle(
            color: textColor,
            fontSize: 30
          )
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: boxColor
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _draw(context);
  }
}