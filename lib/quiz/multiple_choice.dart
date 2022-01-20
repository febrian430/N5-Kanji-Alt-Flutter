import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/submit_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game_components/game_helper.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/quiz/buttons.dart';

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

  Set<int> answeredIndexes = {};
  
  late int totalQuestion = widget.questionSets.length;

  int currentPage = 0;
  PageController _controller = PageController(
    viewportFraction: 1,
    initialPage: 0,
    keepPage: false,
  );

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
          answeredIndexes.add(index);
        }
      });

      var unansweredIndex = GameHelper.nearestUnansweredIndex(index, answeredIndexes, widget.questionSets.length-1);
      if(unansweredIndex != null) {
        animateToPage(unansweredIndex);
      }
  }

  void animateToPage(int target) {
    _controller.animateToPage(
      target, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.linear
    );
  }

  Widget _buildMultipleChoiceRound(BuildContext context, int index, QuizQuestionSet set) {
    return MultipleChoiceRound(
      mode: widget.mode,
      question: set.question,
      options: set.options,
      index: index,
      onSelect: _handleOnSelectQuiz,
      quiz: true,
      isOver: widget.quizOver,
      restartSource: restart,     
    );
  }

  Widget _build(BuildContext context, List<QuizQuestionSet> items) {
    final unanswered = totalQuestion - solved;

    return Column(
      children: [
        Flexible(
          flex: 15,
          child: PageView.builder(
              // store this controller in a State to save the carousel scroll position
            pageSnapping: true,
            onPageChanged: (int page) {
              setState(() {
                currentPage = page;
              });
            },
            controller: _controller,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return  _buildMultipleChoiceRound(context, index, items[index]);
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: GameButtons(
            buttonVisible: !widget.quizOver && solved == totalQuestion, 
            onPrev: (){
              animateToPage(currentPage-1);
            }, 
            onNext: (){
              animateToPage(currentPage+1);
            }, 
            onButtonClick: (){
              var correctKanjis = correctIndexes.map((index) => widget.questionSets[index].fromKanji).toList();
              widget.onSubmit(correct, wrong+unanswered, correctKanjis);
              wasSubmitted = true;
            }, 
            title: "Start Jumble", 
            count: totalQuestion, 
            current: currentPage
          )
        )
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