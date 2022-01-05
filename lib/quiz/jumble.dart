import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/submit_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/jumble/quiz_round.dart';

class JumbleQuizGame extends StatefulWidget {

  final GAME_MODE mode;
  final List<JumbleQuizQuestionSet> questionSets;
  final bool quizOver;
  final Function(int correct, int misses, List<List<int>> score) onSubmit;

  const JumbleQuizGame({Key? key, required this.mode, required this.questionSets, required this.onSubmit, this.quizOver = false}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => _JumbleQuizGameState();
}

class _JumbleQuizGameState extends State<JumbleQuizGame> {
  
  int solved = 0;
  int correct = 0;
  int misses = 0;
  bool initial = true;
  bool initialBuild = true;
  int loaded = 0;
  List<List<int>> correctKanjis = [];

  late List<int> lengthOfRound = []; 
  late bool isGameOver = widget.quizOver;
  late int totalQuestion = widget.questionSets.length;

  

  Widget _buildRound(BuildContext context, int index, JumbleQuizQuestionSet set) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
      child: JumbleQuizRound(
        index: index,
        mode: widget.mode, 
        question: set.question, 
        options: set.options, 
        isOver: isGameOver || widget.quizOver,
        onComplete: (bool isCorrect, int misses, bool init) {
          setState(() {
            if(init) {
              solved++;
            }
          });
        },
        onSubmit: (bool isCorrect, int miss, int index) {
          setState(() {
            if(isCorrect) {
              correct++;
              correctKanjis.add(widget.questionSets[index].fromKanji);
            }
            misses += miss;
            loaded++;
            isGameOver = true;
          });
        },
      ),
    );
  }

  Widget _build(BuildContext context, List<JumbleQuizQuestionSet> items) {
    return Column(children: [
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
          },
          controller: PageController(
            viewportFraction: 1,
            initialPage: 0,
          ),
          children: items.mapIndexed((questionSet, index) {
            if(initialBuild){
              lengthOfRound.add(questionSet.question.key.length);
            }
            return _buildRound(context, index, questionSet);
          }).toList(),
        )
      ),
      Flexible(
        flex: 1,
        child: SubmitButton(
            visible: (!isGameOver || !widget.quizOver) && solved == totalQuestion, 
            onTap: () {
              setState(() {
                isGameOver = true;
              });
            }
          )
      )
    ]
    );
  }
  
  @override
  Widget build(BuildContext context) {
    print(lengthOfRound);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if((isGameOver || widget.quizOver) && initial ) {
        print(lengthOfRound);
        var unansweredCount = lengthOfRound.reduce((sum, miss) => sum + miss);
        var answeredQuestion = lengthOfRound.where((val) => val == 0).length;

        // print('unanswered: ${unansweredCount.toString()}');
        // print('misses: ${misses.toString()}');

        //taro lengthOfRound[index] dimana user udah akses round
        //

        if (answeredQuestion == totalQuestion && loaded == totalQuestion){
          widget.onSubmit(correct, misses, correctKanjis);
          setState(() {
            initial = false;
          });
          //handle if jumble questoin not even reached
        } else if (answeredQuestion < totalQuestion && loaded == answeredQuestion) {
          widget.onSubmit(correct, misses+unansweredCount, correctKanjis);
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