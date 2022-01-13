import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/submit_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/quiz/next_button.dart';

class MultipleChoiceQuizGame extends StatefulWidget {
  const MultipleChoiceQuizGame({Key? key, required this.mode, required this.questionSets, required this.onSubmit, this.quizOver = false, required this.restartSource}) : super(key: key);

  final GAME_MODE mode;
  final List<QuizQuestionSet> questionSets;
  final Function(int correct, int wrong, List<List<int>> correctKanjis) onSubmit;
  final bool quizOver;

  final bool restartSource;

  @override
  State<StatefulWidget> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceQuizGame> {
  int correct = 0;
  int wrong = 0;
  int solved = 0;
  List<int> correctIndexes = [];
  bool initialRerender = true;

  bool restart = false;
  bool wasSubmitted = false;
  
  late int totalQuestion = widget.questionSets.length; 

  void onRestart() {
    setState(() {
      correct = 0;
      wrong = 0;
      solved = 0;
      correctIndexes = [];
      initialRerender = true;
    });
  }

  void _handleOnSelectQuiz(bool isCorrect, int index, bool? wasCorrect) {
      setState(() {
        if(wasCorrect == true) {
          correct--;
          correctIndexes.remove(index);
        } else if(wasCorrect == false) {
          wrong--;
        }

        if(isCorrect){
          correct++;
          correctIndexes.add(index);
        } else {
          wrong++;
        }

        if(wasCorrect == null) {
          solved++;
        }
      });
  }

  Widget _buildMultipleChoiceRound(BuildContext context, int index, QuizQuestionSet set) {
    final unanswered = totalQuestion - solved;
    return Container(
      child: Column(
        children: [
          Expanded(
            flex: 15,
            child: MultipleChoiceRound(
              mode: widget.mode,
              question: set.question,
              options: set.options,
              index: index,
              onSelect: _handleOnSelectQuiz,
              quiz: true,
              isOver: widget.quizOver,
              restartSource: restart,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                EmptyFlex(flex: 1),
                Expanded(
                  flex: 2,
                  child: VisibleButton(
                    onTap: () {
                      var correctKanjis = correctIndexes.map((index) => widget.questionSets[index].fromKanji).toList();
                      widget.onSubmit(correct, wrong+unanswered, correctKanjis);
                      wasSubmitted = true;
                    }, 
                    visible: !widget.quizOver && solved == totalQuestion,
                    title: "Next",
                  )
                ),
                EmptyFlex(flex: 1)
              ]
            )
          )
        ]
      )
    );
  }

  Widget _build(BuildContext context, List<QuizQuestionSet> items) {
    return Column(
      children: [
        Flexible(
          flex: 9,
          child: PageView.builder(
              // store this controller in a State to save the carousel scroll position
            pageSnapping: true,
            controller: PageController(
              viewportFraction: 1,
              initialPage: 0,
              keepPage: false,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildMultipleChoiceRound(context, index, items[index]);
            },
          ),
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(restart){
        setState(() {
          restart = false;
        });
      }

      if(!wasSubmitted && widget.quizOver && initialRerender) {
        final unanswered = totalQuestion - solved;
        var correctKanjis = correctIndexes.map((index) => widget.questionSets[index].fromKanji).toList();
        widget.onSubmit(correct, wrong+unanswered, correctKanjis);
        // setState(() {
          initialRerender = false;
        // });
      }
    });
    return _build(context, widget.questionSets);
  }
}