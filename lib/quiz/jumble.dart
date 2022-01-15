import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/submit_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/jumble/quiz_round.dart';
import 'package:kanji_memory_hint/quiz/buttons.dart';

class JumbleQuizGame extends StatefulWidget {

  final GAME_MODE mode;
  final List<JumbleQuizQuestionSet> questionSets;
  final bool quizOver;
  final Function(int correct, int hits, int misses, List<List<int>> score) onSubmit;
  final bool restartSource;

  const JumbleQuizGame({Key? key, 
    required this.mode, 
    required this.questionSets, 
    required this.onSubmit, 
    this.quizOver = false, 
    required this.restartSource, 
  }) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => _JumbleQuizGameState();
}

class _JumbleQuizGameState extends State<JumbleQuizGame> {
  
  int solved = 0;
  int correct = 0;
  int hits = 0;
  int misses = 0;
  bool initial = true;
  bool initialBuild = true;
  int loaded = 0;
  List<List<int>> correctKanjis = [];

  int currentPage = 0;
  PageController _controller = PageController(
    viewportFraction: 1,
    initialPage: 0,
  );

  bool restart = false;

  late List<int> lengthOfRound = []; 
  late bool isGameOver = widget.quizOver;
  late int totalQuestion = widget.questionSets.length;

  void onRestart() {
    setState(() {
      solved = 0;
      correct = 0;
      hits = 0;
      misses = 0;
      initial = true;
      initialBuild = true;
      loaded = 0;
      correctKanjis = [];

      restart = true;
    });
  }

  void animateToPage(int target) {
    _controller.animateToPage(target, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.linear
    );
  }

  Widget _buildRound(BuildContext context, int index, JumbleQuizQuestionSet set) {
    return Container(
      decoration: BoxDecoration(
        // border: Border.all(
        //   width: 1
        // )
      ),
      child: JumbleQuizRound(
        index: index,
        restartSource: restart,
        mode: widget.mode, 
        question: set.question, 
        options: set.options, 
        isOver: isGameOver || widget.quizOver,
        onComplete: (bool isCorrect, int hit, int misses, bool init) {
          setState(() {
            if(init) {
              solved++;
            }
          });
        },
        onSubmit: (bool isCorrect, int hit, int miss, int index) {
          setState(() {
            if(isCorrect) {
              correct++;
              correctKanjis.add(widget.questionSets[index].fromKanji);
            }
            misses += miss;
            hits += hit;
            loaded++;
            isGameOver = true;
          });
        },
      ),
    );
  }

  Widget _build(BuildContext context, List<JumbleQuizQuestionSet> items) {
    return Column(
      children: [
        Flexible(
          flex: 15,
          child: PageView(
            onPageChanged: (int index){
              if(lengthOfRound[index] != 0){
                lengthOfRound[index] = 0;
              };

              if(lengthOfRound[0] != 0) {
                lengthOfRound[0] = 0;
              }
              setState(() {
                currentPage = index;
              });
            },
            controller: _controller,
            children: items.mapIndexed((questionSet, index) {
              if(initialBuild){
                lengthOfRound.add(questionSet.question.key.length);
              }
              return _buildRound(context, index, questionSet);
            }).toList(),
          )
        ),

        Expanded(
            flex: 2,
            child: GameButtons(
              buttonVisible: (!isGameOver || !widget.quizOver) && solved == totalQuestion,
              onButtonClick: (){
                setState(() { 
                  widget.onSubmit(correct, hits, misses, correctKanjis);
                  isGameOver = true;
                });
              },
              title: "Finish",
              current: currentPage,
              count: widget.questionSets.length,
              onNext: (){
                animateToPage(currentPage+1);
              },
              onPrev: (){
                animateToPage(currentPage-1);
              },
            )
          )
      ]
    );
  }
  
  @override
  Widget build(BuildContext context) {
    print(lengthOfRound);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(restart){
        setState(() {
          restart = false;
        });
      }

      if((isGameOver || widget.quizOver) && initial ) {
        print(lengthOfRound);
        var unansweredCount = lengthOfRound.reduce((sum, miss) => sum + miss);
        var answeredQuestion = lengthOfRound.where((val) => val == 0).length;

        // print('unanswered: ${unansweredCount.toString()}');
        // print('misses: ${misses.toString()}');

        //taro lengthOfRound[index] dimana user udah akses round
        //

        if (answeredQuestion == totalQuestion && loaded == totalQuestion){
          widget.onSubmit(correct, hits, misses, correctKanjis);
          setState(() {
            initial = false;
          });
          //handle if jumble questoin not even reached
        } else if (answeredQuestion < totalQuestion && loaded == answeredQuestion) {
          widget.onSubmit(correct, hits, misses+unansweredCount, correctKanjis);
          setState(() {
            initial = false;
          });
        }
      }
    });
    var gameScreen =  _build(context, widget.questionSets);
    initialBuild = false;
    return gameScreen;
  }
}