import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/quiz/next_button.dart';
import 'package:kanji_memory_hint/quiz/repo.dart';

class Quiz extends StatefulWidget {
  const Quiz({Key? key, required this.mode, required this.chapter}) : super(key: key);

  final GAME_MODE mode;
  final int chapter;
  static const route = "/quiz";
  static const name = "Quiz";

  Future<List> _getQuizQuestionSet() async {
    return getQuizQuestions(chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {

  var quizQuestionSet;
  
  int score = 0;

  int mulchoiceCorrect = 0;
  int mulchoiceWrong = 0;

  int jumbleCorrect = 0;
  int jumbleWrong = 0;

  int gameIndex = 0;

  late int jumbleLength;

  @override
  void initState() {
    super.initState();
    quizQuestionSet = widget._getQuizQuestionSet();
  }

  // Widget _buildNextButton(BuildContext context) {
  //   if()
  // }

  void _handleMultipleChoiceSubmit(int correct, int wrong, int score) {
    setState(() {
      mulchoiceCorrect = correct;
      mulchoiceWrong = wrong;
      score += score;
      gameIndex = 1;
    });
  }
  

  Widget _buildJumbleRound(BuildContext context, int index, JumbleQuestionSet set) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
      child: JumbleRound(
        mode: widget.mode, 
        question: set.question, 
        options: set.options, 
        onRoundOver: (int attempts) {
          print(attempts);
        }
      )
    );
  }

  Widget _buildJumble(BuildContext context, int gameIndex, List<JumbleQuestionSet> items) {
    print("jubmle was called");
    return PageView.builder(
              // store this controller in a State to save the carousel scroll position
              controller: PageController(
                viewportFraction: 1,
                initialPage: 0
              ),
              
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                print("JUMBLE INDEX" + index.toString());
                return _buildJumbleRound(context, index, items[index]);
              },
      );
  }

  Widget _build(BuildContext context, int gameIndex, List items) {
    List<QuestionSet> mcQuestionSets = items[0];
    List<JumbleQuestionSet> jumbleQuestionSets = items[1];

    jumbleLength = jumbleQuestionSets.length;

    return IndexedStack(
      index: gameIndex,
      children: [
        _MultipleChoiceGame(
          mode: widget.mode, 
          questionSets: mcQuestionSets, 
          onSubmit: _handleMultipleChoiceSubmit,
        ),
        _buildJumble(context, gameIndex, jumbleQuestionSets)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: quizQuestionSet,
          builder: (context, AsyncSnapshot<List> snapshot) {
            if(snapshot.hasData) {
              return _build(context, gameIndex, snapshot.data!);
            } else {
              return LoadingScreen();
            }
          }
        ) 
      )
    );
  }
}

class _MultipleChoiceGame extends StatefulWidget {
  const _MultipleChoiceGame({Key? key, required this.mode, required this.questionSets, required this.onSubmit}) : super(key: key);

  final GAME_MODE mode;
  final List<QuestionSet> questionSets;
  final Function(int correct, int wrong, int score) onSubmit;


  @override
  State<StatefulWidget> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<_MultipleChoiceGame> {
    int correct = 0;
    int wrong = 0;
    int solved = 0;

    late int totalQuestion = widget.questionSets.length; 

  void _handleOnSelectQuiz(bool isCorrect, int index, bool? wasCorrect) {
      setState(() {
        if(wasCorrect == true) {
          correct--;
        } else if(wasCorrect == false) {
          wrong--;
        }

        if(isCorrect){
          correct++;
        } else {
          wrong++;
        }

        if(wasCorrect == null) {
          solved++;
        }
      });
  }

  Widget _buildMultipleChoiceRound(BuildContext context, int index, QuestionSet set) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
      child: Column(
        children: [
          MultipleChoiceRound(
            mode: widget.mode,
            question: set.question,
            options: set.options,
            index: index,
            onSelect: _handleOnSelectQuiz,
            quiz: true,
          ),

          NextQuizRoundButton(
            onTap: () {
              widget.onSubmit(correct, wrong, correct*100); //TODO: fix score calc
            }, 
            visible: solved == totalQuestion)
        ]
      )
    );
  }

  Widget _build(BuildContext context, List<QuestionSet> items) {
    return PageView.builder(
              // store this controller in a State to save the carousel scroll position
              pageSnapping: true,
              controller: PageController(
                viewportFraction: 1,
                initialPage: 0
              ),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                print("MULCHOICE " + index.toString());
                return _buildMultipleChoiceRound(context, index, items[index]);
              },
      );
  }

  @override
  Widget build(BuildContext context) {
    return _build(context, widget.questionSets);
  }
}