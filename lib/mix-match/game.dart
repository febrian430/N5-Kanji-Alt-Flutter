import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/menu_screens/game_screen.dart';
import 'package:kanji_memory_hint/mix-match/repo.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/scoring/practice/mix_match.dart';
import 'package:kanji_memory_hint/scoring/model.dart';

typedef OnRoundOverCallback = Function(bool isCorrect, int correct, int wrongAttempts);

class MixMatchGame extends StatefulWidget {
  MixMatchGame({Key? key, required this.chapter, required this.mode}) : super(key: key);

  final int chapter;
  final GAME_MODE mode;
  final int numOfRounds = 2;
  final Stopwatch stopwatch = Stopwatch();

  static const route = '/game/mix-match';
  static const name = 'Mix and Match';

  Future<List<List<Question>>> _getQuestionSet(int chapter, GAME_MODE mode) async {
    return MixMatchQuestionMaker.makeOptions(8, chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _MixMatchGameState();
}

class _MixMatchGameState extends State<MixMatchGame> {
  var _questionSet;

  int roundsSolved = 0;
  int perfect = 0;
  int wrong = 0;
  var _pageController = PageController(viewportFraction: 1,);

  late PracticeScore score;
  late GameResult result;
  late PracticeGameReport report;

  @override
  void initState() {
    super.initState();
    // PracticeGameArguments arg = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;
    _questionSet = widget._getQuestionSet(widget.chapter, widget.mode);
  }

  void _onRoundOver(bool isCorrect, int correct, int wrongAttempts) {
    wrong += wrongAttempts;
    if(wrongAttempts == 0) {
      perfect++;
    }

    setState(() {
      roundsSolved++;    
    });

    if(roundsSolved == widget.numOfRounds){
      widget.stopwatch.stop();
      score = PracticeScore(perfectRounds: perfect, wrongAttempts: wrong);
      result = MixMatchScoring.evaluate(score);
      report = PracticeGameReport(
          game: MixMatchGame.name,
          chapter: widget.chapter,
          mode: widget.mode,
          gains: result,
          result: score
        );

      PracticeQuestHandler.checkForQuests(report);
    }
  }

  Widget _buildRound(BuildContext context, int index, List<List<Question>> data) {
    final size = MediaQuery.of(context).size;

    

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: 
          Container(
            height: size.height*0.85,
            child: _MixMatchRound( 
              options: data[index], 
              onRoundOver: _onRoundOver,
            )
          ),
          
    );
  }

  Widget _buildGame(BuildContext context) {
    Widget resultButton = EmptyWidget;
    if(widget.numOfRounds == roundsSolved) {
      resultButton = ResultButton(
        param: ResultParam(result: result, score: score, stopwatch: widget.stopwatch),
        visible: widget.numOfRounds == roundsSolved,
      );
    }
    return Column(
      children: [
        Flexible(
          flex: 15,
          child: Center(
            child: FutureBuilder(
              future: _questionSet,
              builder: (context, AsyncSnapshot<List<List<Question>>> snapshot) {
                if(snapshot.hasData) {
                  return PageView.builder(
                    controller: _pageController,
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
          )
        ),
        Flexible(
          flex: 1,
          child: resultButton
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.stopwatch.start();
    return GameScreen(
      game: _buildGame(context),
      title: MixMatchGame.name,
      japanese: "in japanese",
      onRestart: onRestart,
      onContinue: onContinue,
      onPause: onPause,
    );   
  }

  onContinue() {
    widget.stopwatch.start();
  }

  onPause() {
    widget.stopwatch.stop();
  }

  onRestart() {
    setState(() {
      roundsSolved = 0;
      perfect = 0;
      wrong = 0;
      _questionSet = widget._getQuestionSet(widget.chapter, widget.mode);
      _pageController.animateToPage(0, duration: Duration(milliseconds: 250), curve: Curves.linear);  
    });
    widget.stopwatch.reset();
  }
}

class _MixMatchRound extends StatefulWidget {
  
  _MixMatchRound({Key? key, required this.options, required this.onRoundOver}): super(key: key);

  final List<Question> options;
  final OnRoundOverCallback onRoundOver;

  @override
  State<StatefulWidget> createState() => _MixMatchRoundState();
}

class _MixMatchRoundState extends State<_MixMatchRound> with AutomaticKeepAliveClientMixin {
  int score = 0;
  int wrong = 0;
  late int numOfQuestions; 

  Question? selected;
  List<Question> solved = [];


  @override
  bool get wantKeepAlive => true;


  Widget _drawQuestionWidget(BuildContext context, Question opt) {
    bool isSelected = (selected?.id == opt.id);
    bool isSolved = solved.contains(opt);

    final boxSize = MediaQuery.of(context).size.width*0.20;

    if(opt.isImage){
      double opacity = isSelected || isSolved ? 0.5 : 1;
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(KANJI_IMAGE_FOLDER + opt.value),
            fit: BoxFit.fill,
            
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(opacity), BlendMode.dstATop)
          ),
          border: isSelected ? Border.all(
            color:  Colors.green,
            width: 2
          ) : null,
        ),
        height: boxSize,
        width: boxSize,
      );
    } else {
    
      BoxDecoration? deco;

      if(isSelected) {
        deco = BoxDecoration(
            border: Border.all(
              color: Colors.green,
              width: 2
            )
          );
      } else if(isSolved) {
        deco = BoxDecoration(
            border: Border.all(
              color: Colors.red,
              width: 2
            )
          );
      } else {
        deco = BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1
            )
          );
      }

      return Container( 
        child: Center(
          child: Text(opt.value + " " + opt.key),
        ),
        decoration: deco,
        height: 120,
        width: 120,
      );
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

  void _isGameOver() async {
    if(solved.length == numOfQuestions){
      widget.onRoundOver(true, score, wrong);
      showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AlertDialog(
              title: const Text('Game over'),
              content: Text('Wrong attempts: ' + wrong.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            )
          );
        }
      );
    }
  }

  void _evaluate(Question opt) {
    if(selected?.key == opt.key) {
      setState(() {
        solved = [...solved, opt, selected!];
        selected = null;
      });
      _isGameOver();
      print("correct");
    } else {
      setState(() {
        selected = null;
        wrong++;
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

  Widget _buildQuestion(BuildContext context, Question opt) {
    return GestureDetector(
            child: Container(
              child: _drawQuestionWidget(context, opt)
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
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: NeverScrollableScrollPhysics(),
                children: questions.map((opt) {
                  return _buildQuestion(context, opt);
                }).toList(),
              )
            )
          ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // PracticeGameArguments arg = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;
    
    return _getGameUI(context, widget.options);
  }


}