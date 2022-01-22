import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/audio_repository/audio.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game_components/game_helper.dart';
import 'package:kanji_memory_hint/game_components/question_widget.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/images.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/jumble/repo.dart';
import 'package:kanji_memory_hint/levelling/levels.dart';
import 'package:kanji_memory_hint/menu_screens/game_screen.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/foreach_indexed.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/scoring/practice/jumble.dart';
import 'package:kanji_memory_hint/scoring/report.dart';
import 'package:kanji_memory_hint/theme.dart';
import 'package:kanji_memory_hint/user_games/games_played.dart';


class JumbleGame extends StatefulWidget {
  JumbleGame({Key? key, required this.mode, required this.chapter, this.prevQuestions}) : super(key: key);

  static const route = '/game/jumble';
  static const name = 'Jumble';

  final GAME_MODE mode;
  final int chapter;
  final bool isQuiz = false;
  final Stopwatch stopwatch = Stopwatch();
  final List<JumbleQuestionSet>? prevQuestions;

  Future<List<JumbleQuestionSet>> _getQuestionSet() async {
    return JumbleQuestionMaker.makeQuestionSet(GameNumOfRounds, chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _JumbleGameState();
}

class _JumbleGameState extends State<JumbleGame> {
  final PageController _pageController =  PageController(
    viewportFraction: 1,
    initialPage: 0  
  );

  List<JumbleQuestionSet> restartQuestions = [];

  int score = 0;
  int wrongCount = 0;
  int solved = 0;
  int perfect = 0;
  Set<int> solvedIdx = {};
  List<int> perfectRoundsSlots = [];

  List<int> slots = [];
  List<int> attempts = [];

  int currentPage = 0;

  late int slotsToFill;
  int numOfQuestions = GameNumOfRounds;

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
    // setState(() {
    //   currentPage=0;
    //   score = 0;
    //   wrongCount = 0;
    //   solved = 0;
    //   perfect = 0;
    //   solvedIdx = {};
    //   slotsToFill = 0;
    //   numOfQuestions = 10;
    //   _questionSets =  widget._getQuestionSet();
    //   restart = true;
    //   _pageController.animateToPage(0, duration: const Duration(seconds: 0), curve: Curves.linear);
    // });
    onRestartFromResult();
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
    if(restartQuestions.isEmpty) {
      arg.jumbleRestart = widget.prevQuestions;
    } else {
      arg.jumbleRestart = restartQuestions;
    }

    Navigator.of(context).pushReplacementNamed(
      JumbleGame.route, 
      arguments: arg
    );
  }

  void _handleRoundOver(bool isCorrect, int misses, int index, int slotsToFill, int wrongAttempts) {
    setState(() {
      if(isCorrect) {
        if(wrongAttempts == 0) {
          perfect++;
          perfectRoundsSlots.add(slotsToFill);
        }

        slots.add(slotsToFill);
        attempts.add(wrongAttempts);
        
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
          attemptsPerRound: attempts,
          chapter: widget.chapter,
          mode: widget.mode
        );
        result = JumbleScoring.evaluate(endScore, slots, perfectRoundsSlots);
        report = PracticeGameReport(
          game: JumbleGame.name,
          chapter: widget.chapter,
          mode: widget.mode,
          gains: result,
          result: endScore
        );

        PracticeQuestHandler.checkForQuests(report);
        Levels.addExp(result.expGained);
        print("gained: ${result.expGained}");
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
    var fromPrevGame = widget.prevQuestions;
    if(fromPrevGame == null) {
      return FutureBuilder(
        future: _questionSets,
        builder: (context, AsyncSnapshot<List<JumbleQuestionSet>> snapshot) {
          if(snapshot.hasData) {
            if(restartQuestions.isEmpty) {
              restartQuestions = snapshot.data!;
            }
            widget.stopwatch.start();
            numOfQuestions = snapshot.data!.length;
            int sum = 0;
            var screen =  PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  currentPage = page;
                });
              },
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
      );
    } else {
      widget.stopwatch.start();
      numOfQuestions = fromPrevGame.length;
      int sum = 0;
        var screen =  PageView.builder(
          controller: _pageController,
          onPageChanged: (int page) {
            setState(() {
              currentPage = page;
            });
          },
          itemCount: fromPrevGame.length,
          itemBuilder: (BuildContext context, int itemIndex) {
            sum += fromPrevGame[itemIndex].question.key.length;
            return _buildRound(context, itemIndex, fromPrevGame);
          },
        );
        slotsToFill = sum;
        return screen;
    }
    
  }

  @override
  Widget build(BuildContext context) {

    GuideDialog guide = GuideDialog(
      game: JumbleGame.name,
      description: "Select the correct hiragana in the correct order",
      guideImage: AppImages.guideJumble,
      onClose: onContinue,
    );

    WidgetsBinding.instance?.addPostFrameCallback((_){
      if(restart){
        setState(() {
          restart = false;
        });
      }

      if(!GamesPlayed.jumble){
        showDialog(context: context, builder: (context) => guide);
        GamesPlayed.setJumbleTrue();
      }
    });


    return GameScreen(
      title: JumbleGame.name, 
      japanese: "ごちゃ混ぜ", 
      icon: AppIcons.jumble,
      isGameOver: solved == numOfQuestions,
      game: _buildGame(context), 
      onPause: onPause, 
      onRestart: onRestart, 
      onContinue: onContinue,
      onGuideOpen: onPause,
      prevVisible: currentPage != 0,
      nextVisible: currentPage != (numOfQuestions-1),
      onNext: (){
        setState(() {
          _pageController.animateToPage(++currentPage, duration: const Duration(milliseconds: 200), curve: Curves.linear);  
        });
      },
      onPrev: (){
        setState(() {
          _pageController.animateToPage(--currentPage, duration: const Duration(milliseconds: 200), curve: Curves.linear);
        });
      },
      footer: numOfQuestions == solved ? 
      ResultButton(
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
      ) : SizedBox(),
      guide: guide
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
  final Function(bool isCorrect, int misses, int index, int slotsToFill, int wrongAttempts) onComplete;

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

  List<int> wrongSelected = [];

  int attempts = 0;
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
      roundColor = Colors.transparent;
      selectCount = 0;
      misses = 0;
      attempts = 0;
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
      selectCount = max(0, selectCount -= indexes.length);

      wrongSelected = [];
    });
  }

  void _handleSelectTap(Option option, int index) {
    if(!isRoundOver && wrongSelected.isEmpty){
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
    if(!isRoundOver && wrongSelected.isEmpty){

      if(selected.contains(option)){
        
        var index = selected.indexOf(option);
        print("UNSELECTING INDEX: $index");
        _unselect([index]);
        
        return;
      }

      int firstEmpty = _firstEmptySlot();
      if(firstEmpty != -1){
        setState(() {
          selected[firstEmpty] = option;
          selectCount++;
        });
      }
      print("sel count$selectCount : total length ${widget.question.key.length}");
      if(selectCount == widget.question.key.length) {
        var diff = _differentIndexes();
        if(diff.length == 0) {
          setState(() {
            isRoundOver = true;
            roundColor = _correctColor;
            SoundFX.correct();
            widget.onComplete(true, 0, widget.index, widget.question.key.length-1, attempts);
          });
        } else {
          setState(() {
            misses += diff.length;
            wrongSelected.addAll(diff);
            // roundColor = _wrongColor;
            widget.onComplete(false, diff.length, widget.index, widget.question.key.length-1, attempts);
          });
        }
        attempts++;

        Future.delayed(const Duration(milliseconds: 500), () {
          _unselect(diff);
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
              return OptionWidget(option: opt, selected: selected.contains(opt), disabled: false, onTap: () { _handleOptionTap(opt); },);
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: opts.skip(4).map((opt) {
              return OptionWidget(option: opt, selected: selected.contains(opt), disabled: false, onTap: () { _handleOptionTap(opt); },);
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

    return Center(
      child: Container(
        // height: MediaQuery.of(context).size.height - 120,
        decoration: BoxDecoration(
          // border: Border.all(
          //   width: 1,
          // ),
          color: Colors.transparent
        ),
        //question
        child: Column(
          children: [
            Flexible(
              flex:17,
              child: QuestionWidget(mode: widget.mode, questionStr: widget.question.value),
            ),
            // Text(widget.question.key.join('')),
            EmptyFlex(flex: 1),
            //selected box
            Flexible(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: selected.mapIndexed((select, i) {
                    print("${select.id} in wrong :  ${wrongSelected.contains(i)}");
                    return Container(
                      margin: EdgeInsets.only(left: 4, right: 4),
                      child: SelectWidget(
                        option: select, 
                        isRoundOver: isRoundOver, 
                        onTap: () { 
                          _handleSelectTap(select, i); 
                        },
                        forceColor: wrongSelected.contains(i) ? AppColors.wrong : null,
                      )
                    );
                  }).toList(),
              ),
            ),
            EmptyFlex(flex: 1),
            //options
            // Expanded(
            Flexible(
              flex: 8,
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

typedef OnTapFunc = Function();

class SelectWidget extends StatelessWidget {
  SelectWidget({
    Key? key, 
    required this.option, 
    required this.isRoundOver, 
    required this.onTap,
    this.forceColor, 
  }): super(key: key);

  final Option option;
  final bool isRoundOver;
  final OnTapFunc onTap;
  Color? forceColor;

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

    bgColor = forceColor ?? bgColor;

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
              ),
              child: Center(
                child: Text(
                  !_isSentinel() ? option.value : "",
                  style: TextStyle(
                    fontWeight: forceColor != null ? FontWeight.bold : null,
                    color: forceColor != null ? Colors.white : null
                  ),
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
  const OptionWidget({
      Key? key, 
      required this.option, 
      this.disabled = false, 
      required this.onTap,
      required this.selected
    }) : super(key: key);
  
  final Option option;
  final bool disabled;
  final OnTapFunc onTap;
  final bool selected;

  Widget _draw(BuildContext context) {
    Color boxColor = AppColors.primary;
    Color textColor = Colors.black;

    if(disabled) {
      boxColor = AppColors.selected;
      textColor = AppColors.selected;
    } else  if(selected) {
      boxColor = AppColors.selected;
      textColor = Colors.black;
    }

    return TextButton(
      onPressed: () {
        if(!disabled) {
          onTap();
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // border: Border.all(
          //   // width: 1
          // )
        ),
        height: 45,
        width: 60,
        child: Text(  
          option.value,
          style: TextStyle(
            color: textColor,
            fontSize: 25,
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