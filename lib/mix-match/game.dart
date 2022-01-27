import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/audio_repository/audio.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/images.dart';
import 'package:kanji_memory_hint/levelling/levels.dart';
import 'package:kanji_memory_hint/menu_screens/game_screen.dart';
import 'package:kanji_memory_hint/mix-match/repo.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/scoring/practice/mix_match.dart';
import 'package:kanji_memory_hint/scoring/report.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/theme.dart';
import 'package:kanji_memory_hint/user_games/games_played.dart';



class MixMatchGame extends StatefulWidget {
  MixMatchGame({Key? key, required this.chapter, required this.mode, this.prevQuestions}) : super(key: key);

  final int chapter;
  final GAME_MODE mode;
  final int numOfRounds = 2;
  final Stopwatch stopwatch = Stopwatch();
  final List<List<Question>>? prevQuestions;

  static const route = '/game/mix-match';
  static const name = 'Mix and Match';

  Future<List<List<Question>>> _getQuestionSet(int chapter, GAME_MODE mode) async {
    return MixMatchQuestionMaker.makeOptions(6, chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _MixMatchGameState();
}

class _MixMatchGameState extends State<MixMatchGame> {
  var _questionSet;

  List<List<Question>> restartQuestions = [];

  int currentPage = 0;
  int roundsSolved = 0;
  int perfect = 0;
  int wrong = 0;
  bool restart = false;
  var _pageController = PageController(viewportFraction: 1,);

  List<int> attempts = [];

  late PracticeScore score;
  late GameResult result;
  late PracticeGameReport report;

  @override
  void initState() {
    super.initState();    
    _questionSet = widget._getQuestionSet(widget.chapter, widget.mode);

  }

  void _onRoundOver(bool isCorrect, List<int> attemptsByKey, int wrongAttempts) {
    wrong += wrongAttempts;
    if(wrongAttempts == 0) {
      perfect++;
    }

    setState(() {
      roundsSolved++;    
    });

    attempts.addAll(attemptsByKey);


    if(roundsSolved == widget.numOfRounds){
      widget.stopwatch.stop();
      score = PracticeScore(
        perfectRounds: attempts.where((attempt) => attempt == 0).length, 
        wrongAttempts: wrong,
        attemptsPerRound: attempts,
        chapter: widget.chapter,
        mode: widget.mode
      );
      result = MixMatchScoring.evaluate(score);
      report = PracticeGameReport(
          game: MixMatchGame.name,
          chapter: widget.chapter,
          mode: widget.mode,
          gains: result,
          result: score
        );

      PracticeQuestHandler.checkForQuests(report);
      Levels.addExp(result.expGained);
    } else {
      // _showDialog();
      currentPage++;
      _pageController.animateToPage(
        _pageController.page!.floor() + 1, 
        duration: Duration(milliseconds: 500), 
        curve: Curves.linear
      );
    }
  }

  void onRestartFromResult() {
    var arg = PracticeGameArguments(
      selectedGame: MixMatchGame.route,
      gameType: GAME_TYPE.PRACTICE
    );
    arg.chapter = widget.chapter;
    arg.mode = widget.mode;
    if(restartQuestions.isEmpty) {
      arg.mixMatchRestart = widget.prevQuestions;
    } else {
      arg.mixMatchRestart = restartQuestions;
    }

    Navigator.of(context).popAndPushNamed(
      MixMatchGame.route, 
      arguments: arg
    );
  }

  Widget _buildRound(BuildContext context, int index, List<List<Question>> data) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: 
         _MixMatchRound( 
            options: data[index], 
            onRoundOver: _onRoundOver,
            restartSrc: restart,
          )
        
    );
  }

  Widget _buildGame(BuildContext context) {
    var fromPrevGame = widget.prevQuestions;

    if(fromPrevGame == null) {
      return Center(
        child: FutureBuilder(
          future: _questionSet,
          builder: (context, AsyncSnapshot<List<List<Question>>> snapshot) {
            if(snapshot.hasData) {
              widget.stopwatch.start();
              if(restartQuestions.isEmpty) {
                restartQuestions = snapshot.data!;
              } 
              return PageView.builder(
                controller: _pageController,
                onPageChanged: (int page){
                  setState(() {
                    currentPage = page;
                  });
                },
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int itemIndex) {
                  return _buildRound(context, itemIndex, snapshot.data!);
                }
              );
            } else {
              return LoadingScreen();
            }
          }
        )
      );
    } else {
      widget.stopwatch.start();
      return Center(
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (int page){
            setState(() {
              currentPage = page;
            });
          },
          itemCount: fromPrevGame.length,
          itemBuilder: (BuildContext context, int itemIndex) {
            return _buildRound(context, itemIndex, fromPrevGame);
          }
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    GuideDialog guide = GuideDialog(
      game: MixMatchGame.name,
      description: "Match the Kanji with the image or spelling based on its appropriate meaning",
      guideImage: AppImages.guideMixMatch,
      onClose: onContinue,
    );

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(!GamesPlayed.mixmatch) {
        showDialog(context: context, builder: (context) => guide);
        GamesPlayed.setMixMatchTrue();
      }

      if(restart) {
        setState(() {
          restart = false;
        });
      }
    });

    return GameScreen(
      game: _buildGame(context),
      title: MixMatchGame.name,
      withHorizontalPadding: true,
      japanese: "ミックスマッチ",
      onRestart: onRestart,
      onContinue: onContinue,
      onPause: onPause,
      onGuideOpen: onPause,
      isGameOver: roundsSolved == widget.numOfRounds,
      gameFlex: 8,
      prevVisible: currentPage != 0,
      nextVisible: currentPage != 1,
      icon: AppIcons.mixmatch,
      onNext: (){
        setState(() {
          currentPage++;
          _pageController.animateToPage(currentPage, duration: const Duration(milliseconds: 200), curve: Curves.linear);  
        });
      },
      onPrev: (){
        setState(() {
          --currentPage;
          _pageController.animateToPage(currentPage, duration: const Duration(milliseconds: 200), curve: Curves.linear);
        });
      },
      footer: widget.numOfRounds == roundsSolved ? 
      ResultButton(
        param: ResultParam(
          onRestart: onRestartFromResult,
          route: MixMatchGame.route,
          chapter: widget.chapter,
          game: MixMatchGame.name,
          mode: widget.mode,
          result: result, 
          score: score, 
          stopwatch: widget.stopwatch
        ),
        visible: widget.numOfRounds == roundsSolved,
      ) : SizedBox(),
      guide: guide
    );   
  }

  

  onContinue() {
    widget.stopwatch.start();
  }

  onPause() {
    widget.stopwatch.stop();
  }

  onRestart() {
    // setState(() {
    //   roundsSolved = 0;
    //   perfect = 0;
    //   wrong = 0;
    //   _questionSet = widget._getQuestionSet(widget.chapter, widget.mode);
    //   restart = true;
    // });

    // _pageController.animateToPage(0, duration: Duration(milliseconds: 250), curve: Curves.linear);  
    // widget.stopwatch.reset();
    onRestartFromResult();
  }
}

typedef OnRoundOverCallback = Function(bool isCorrect, List<int> attemptsMap, int wrongAttempts);

class _MixMatchRound extends StatefulWidget {
  
  _MixMatchRound({Key? key, required this.options, required this.onRoundOver, required this.restartSrc}): super(key: key);

  final List<Question> options;
  final bool restartSrc;
  final OnRoundOverCallback onRoundOver;

  @override
  State<StatefulWidget> createState() => _MixMatchRoundState();
}

class _MixMatchRoundState extends State<_MixMatchRound> with AutomaticKeepAliveClientMixin {
  int score = 0;
  int wrong = 0;
  Question? selected;

  List<Question> incorrectSelect = [];
  List<Question> solved = [];
  Map<Question, int> attempts = <Question, int> {};
  Map<String, int> attemptsByKey = <String, int> {};
  Set<String> keys = {};
  bool attemptsLoaded = false;

  late int numOfQuestions; 

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void restart() {
    setState(() {
      score = 0;
      selected = null;
      solved = [];
      wrong = 0;
    });
  }

  Widget _drawQuestionWidget(BuildContext context, int index, Question opt) {
    bool isSelected = (selected?.id == opt.id);
    bool isSolved = solved.contains(opt);

    Color selectedBorderColor = AppColors.selected;
    Color solvedBorderColor = AppColors.correct;
    Color defaultBorderColor = Colors.black;
    const int borderWidth = 2;
    // final Color defaultBackgroundColor = (index + (index / 4).floor()) % 2 == 1 ? AppColors.primary : Colors.white;
    final Color defaultBackgroundColor = AppColors.primary;

    final boxSize = MediaQuery.of(context).size.width*0.20;

    BoxDecoration? deco;
    if(incorrectSelect.contains(opt)) {
      deco = BoxDecoration(
        border: Border.all(
          color: AppColors.wrong,
          width: 3,
        ),
        color: defaultBackgroundColor
      );
    }else if(isSelected) {
      deco = BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 3
          ),
          color: AppColors.selected
        );
    } else if(isSolved) {
      deco = BoxDecoration(
          border: Border.all(
            color: solvedBorderColor,
            width: 4
          ),
          color: defaultBackgroundColor
        );
    } else {
      deco = BoxDecoration(
          border: Border.all(
            color: defaultBorderColor,
            width: 2
          ),
          color: defaultBackgroundColor
        );
    }

    if(opt.isImage){
      double opacity = isSelected ? .4 : 1;
      
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: 8/9.8,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(KANJI_IMAGE_FOLDER + opt.value),
                  fit: BoxFit.contain,
                  
                  colorFilter: ColorFilter.mode(AppColors.selected.withOpacity(opacity), BlendMode.dstATop)
                ),
                border: deco.border,
                color: isSelected ? AppColors.selected : Colors.white
              ),
              height: boxSize,
              width: boxSize
            ),
          ),
          isSolved ? Center(child: Image.asset(AppIcons.checkNoOutline),) : SizedBox()

        ]
        
      );
    }

      final width = MediaQuery.of(context).size.width;
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: 9/11,
            child: Container( 
              // padding: EdgeInsets.symmetric(
              //   horizontal: 5
              // ),
              child: Center(
                child: Text(opt.value,
                // + opt.key,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    height: 1.3
                  ),
                ),
              ),
              decoration: deco,
              width: width*0.25,
            )
          ),
          isSolved ? 
          Center(
            child: Image.asset(
                 AppIcons.checkNoOutline,
                ),
            ) 
          : 
          SizedBox()

        ]
      );
  }

  void _isGameOver() {
    if(solved.length == numOfQuestions){
      var sum  = 0;
      List<int> sumByKey = [];
      for (var opt in widget.options) {
        sum += attempts[opt]!;
      }

      for(var key in keys) {
        var optionsWithKey = widget.options
        .where((opt) => opt.key == key)
        .map((opt) => attempts[opt]).toList();

        var attemptsWithKey = max(optionsWithKey[0]!, optionsWithKey[1]!);
        sumByKey.add(attemptsWithKey);
      }

      widget.onRoundOver(true, sumByKey, wrong);
    }
  }

  void _deselect(Question opt) {
    setState(() {
      selected = null;
    });

    print("deselect " + opt.value.toString());

  }

  void _select(Question opt) {
    setState(() {
      selected = opt;
    });
    print("select " + opt.value.toString());
  }



  void _evaluate(Question opt) {
    if(selected?.key == opt.key) {
      setState(() {
        solved = [...solved, opt, selected!];
        selected = null;
      });
      SoundFX.correct();
      _isGameOver();
    } else {
      SoundFX.wrong();
      attempts[selected!] = attempts[selected!]! + 1;
      // attempts[opt] = attempts[opt]! + 1;

      attemptsByKey[selected!.key] = attemptsByKey[selected!.key]! + 1;
      // attemptsByKey[opt.key] = attemptsByKey[opt.key]! + 1;

      print("${opt.value} is now ${attempts[opt]} ");
      // print("${selected!.value} is now ${attempts[selected!]} ");

      setState(() {
        incorrectSelect = [selected!, opt];
        selected = null;
        wrong++;
      });

      

      Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            incorrectSelect = [];
          });
        });
      print("incorrect");
    }
  }

  void _handleTap(Question opt) {
    if(!solved.contains(opt)) {
      if(selected == null) {
        _select(opt);
      } else if(selected?.value == opt.value) {
        _deselect(opt);
      } else {
        _evaluate(opt);
      }
    }
  }

  Widget _buildQuestion(BuildContext context, int index, Question opt) {
    return GestureDetector(
      child: Container(
        child: _drawQuestionWidget(context, index, opt)
      ),
      onTap:() {
        setState(() {
          _handleTap(opt);
       });
      },
    );
  }

  Widget _getGameUI(BuildContext context, List<Question> questions) {
    numOfQuestions = questions.length;
    return Center(
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 8/11,
        shrinkWrap: true,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        physics: const NeverScrollableScrollPhysics(),
        children: questions.mapIndexed((opt, index) {
          return _buildQuestion(context, index, opt);
        }).toList(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // PracticeGameArguments arg = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;
    WidgetsBinding.instance?.addPostFrameCallback((_){
      if(widget.restartSrc) {
        restart();
      }
      if(!attemptsLoaded) {
        for(int i = 0; i < widget.options.length; i++) {
          attempts[widget.options[i]] = 0;
          attemptsByKey[widget.options[i].key] = 0;
          keys.add(widget.options[i].key);
        }
        attemptsLoaded = true;
      }
    });
    return _getGameUI(context, widget.options);
  }


}