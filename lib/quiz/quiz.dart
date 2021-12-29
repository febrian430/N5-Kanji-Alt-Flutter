import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/submit_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/countdown.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/jumble/quiz_round.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/quiz/footer_nav.dart';
import 'package:kanji_memory_hint/quiz/next_button.dart';
import 'package:kanji_memory_hint/quiz/quiz_result.dart';
import 'package:kanji_memory_hint/quiz/repo.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


class Quiz extends StatefulWidget {
  const Quiz({Key? key, required this.mode, required this.chapter}) : super(key: key);

  final GAME_MODE mode;
  final int chapter;
  static const route = "/quiz";
  static const name = "Quiz";

  Future<List> _getQuizQuestionSet() async {
    return getQuizQuestions(3, chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  _QuizState(){
    _countdown = Countdown(
      startTime: secondsLeft,
      onTick: onCountdownTick,
      onDone: onCountdownOver
    );
  }

  var quizQuestionSet;
  
  
  int secondsLeft = 15;
  int score = 0;

  int mulchoiceCorrect = 0;
  int mulchoiceWrong = 0;

  int jumbleCorrect = 0;
  int jumbleMisses = 0;

  int gameIndex = 0;
  bool isOver = false;

  late final Countdown _countdown;

  @override
  void initState() {
    super.initState();
    quizQuestionSet = widget._getQuizQuestionSet();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _countdown.start();
    });
  }

  void onCountdownTick(int current) {
    setState(() {
      secondsLeft = current;
    });
  }

  void onCountdownOver() {
    setState(() {
      isOver = true;
    });
  }

  // Widget _buildNextButton(BuildContext context) {
  //   if()
  // }

  void _onMCCountdownOver(int correct, int wrong, int score) {
    setState(() {
      mulchoiceCorrect = correct;
      mulchoiceWrong = wrong;
      score += score;
      gameIndex = 2;
    });
  }

  void _onJumbleCountdownOver(int correct, int misses, int score) {
    setState(() {
      jumbleCorrect = correct;
      jumbleMisses = misses;
      score += score;
      isOver = true;
      gameIndex = 2;
    });
  }

  void _handleMultipleChoiceSubmit(int correct, int wrong, int score) {
    setState(() {
      mulchoiceCorrect = correct;
      mulchoiceWrong = wrong;
      score += score;

      if(_countdown.isDone) {
        gameIndex = 2;
      } else {
        gameIndex = 1;
      }
    });
  }

  void _handleJumbleSubmit(int correct, int misses, int score) {
    setState(() {
      jumbleCorrect = correct;
      jumbleMisses = misses;
      score += score;
      isOver = true;
      gameIndex = 2;
    });
  }

  void _goMultipleChoice() {
    setState(() {
      gameIndex = 0;
    });
  }

  void _goJumble() {
    setState(() {
      gameIndex = 1;
    });
  }

  void _goQuizResult() {
    setState(() {
      gameIndex = 2;
    });
  }
  
  Widget _build(BuildContext context, int gameIndex, List items) {
    List<QuestionSet> mcQuestionSets = items[0];
    List<JumbleQuestionSet> jumbleQuestionSets = items[1];


    return Column(
      children: [
        Flexible(
          flex: 1,
          child: CountdownWidget(seconds: secondsLeft)
        ),
        Flexible(
          flex: 10,
          child: IndexedStack(
            index: gameIndex,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                    width: 1,
                  )
                ),
                child: _MultipleChoiceGame(
                  mode: widget.mode, 
                  questionSets: mcQuestionSets, 
                  quizOver: isOver,
                  onSubmit: _handleMultipleChoiceSubmit,
                )
              ),
              _JumbleGame(
                mode: widget.mode,
                questionSets: jumbleQuestionSets,
                quizOver: isOver,
                onSubmit: _handleJumbleSubmit,
              ),
              QuizResult(
                  multipleChoice: QuizGameParam(
                    correct: mulchoiceCorrect, 
                    wrong: mulchoiceWrong, 
                    goHere: _goMultipleChoice
                  ), 
                  jumble: QuizGameParam(
                    correct: jumbleCorrect, 
                    wrong: jumbleMisses, 
                    goHere: _goJumble
                  )
              )
            ],
          )
        ),
        Visibility(
          visible: isOver,
          child: Flexible(
            flex: 1,
            child: IndexedStack(
              index: gameIndex,
              children: [
                FooterNavigation(
                  result: FooterNavigationParam(
                    title: "See result",
                    onTap: _goQuizResult
                  ),
                  next: FooterNavigationParam(
                    title: "Go Jumble",
                    onTap: _goJumble
                  ),
                ),
                FooterNavigation(
                  result: FooterNavigationParam(
                    title: "See result",
                    onTap: _goQuizResult
                  ),
                  prev: FooterNavigationParam(
                    title: "Multiple Choice",
                    onTap: _goMultipleChoice
                  ),
                ),
                FooterNavigation(
                  prev: FooterNavigationParam(
                    title: "Multiple Choice",
                    onTap: _goMultipleChoice
                  ),
                  next: FooterNavigationParam(
                    title: "Jumble",
                    onTap: _goJumble
                  ),
                ),
              ],
            )
          ),
        )
      ]
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
  const _MultipleChoiceGame({Key? key, required this.mode, required this.questionSets, required this.onSubmit, this.quizOver = false}) : super(key: key);

  final GAME_MODE mode;
  final List<QuestionSet> questionSets;
  final Function(int correct, int wrong, int score) onSubmit;
  final bool quizOver;

  @override
  State<StatefulWidget> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<_MultipleChoiceGame> {
    int correct = 0;
    int wrong = 0;
    int solved = 0;

    bool initialRerender = true;
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
    final unanswered = totalQuestion - solved;
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
            isOver: widget.quizOver,
          ),

          NextQuizRoundButton(
            onTap: () {
              widget.onSubmit(correct, wrong+unanswered, correct*100); //TODO: fix score calc
            }, 
            visible: !widget.quizOver && solved == totalQuestion
          )
        ]
      )
    );
  }

  Widget _build(BuildContext context, List<QuestionSet> items) {
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
      if(widget.quizOver && initialRerender) {
        final unanswered = totalQuestion - solved;
        widget.onSubmit(correct, wrong+unanswered, correct*100);
        // setState(() {
          initialRerender = false;
        // });
      }
    });
    return _build(context, widget.questionSets);
  }
}

class _JumbleGame extends StatefulWidget {

  final GAME_MODE mode;
  final List<JumbleQuestionSet> questionSets;
  final bool quizOver;
  final Function(int correct, int misses, int score) onSubmit;

  const _JumbleGame({Key? key, required this.mode, required this.questionSets, required this.onSubmit, this.quizOver = false}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => _JumbleGameState();
}

class _JumbleGameState extends State<_JumbleGame> {
  
  int solved = 0;
  int correct = 0;
  int misses = 0;
  bool initial = true;
  bool initialBuild = true;
  int loaded = 0;

  late List<int> lengthOfRound = []; 
  late bool isGameOver = widget.quizOver;
  late int totalQuestion = widget.questionSets.length;

  

  Widget _buildRound(BuildContext context, int index, JumbleQuestionSet set) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
      child: Column(
        children: [
          JumbleQuizRound(
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
            onSubmit: (bool isCorrect, int miss) {
              setState(() {
                if(isCorrect) {
                  correct++;
                }
                misses += miss;
                loaded++; 

                isGameOver = true;
              });
            },
          ),
          SubmitButton(
            visible: (!isGameOver || !widget.quizOver) && solved == totalQuestion, 
            onTap: () {
              setState(() {
                isGameOver = true;
              });
            }
          )
        ]
      )
    );
  }

  // Widget _build(BuildContext context, List<JumbleQuestionSet> items) {
  //   return Column(children: [
      
  //     Flexible(
  //       flex: 9,
  //       child: PageView.builder(
  //             // store this controller in a State to save the carousel scroll position
  //         controller: PageController(
  //           viewportFraction: 1,
  //           initialPage: 0,
  //         ),
          
  //         itemCount: items.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           return _buildRound(context, index, items[index]);
  //         },
  //       )
  //     ),
  //   ]
  //   );
  // }

  Widget _build(BuildContext context, List<JumbleQuestionSet> items) {
    return Column(children: [
      
      Flexible(
        flex: 9,
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
          widget.onSubmit(correct, misses, 0);
          setState(() {
            initial = false;
          });
          //handle if jumble questoin not even reached
        } else if (answeredQuestion < totalQuestion && loaded == answeredQuestion) {
          widget.onSubmit(correct, misses+unansweredCount, 0);
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