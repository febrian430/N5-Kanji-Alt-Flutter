import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/backgrounds/practice_background.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/submit_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/countdown.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/jumble/quiz_round.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/quests/mastery.dart';
import 'package:kanji_memory_hint/quests/quiz_quest.dart';
import 'package:kanji_memory_hint/quiz/footer_nav.dart';
import 'package:kanji_memory_hint/quiz/multiple_choice.dart';
import 'package:kanji_memory_hint/quiz/next_button.dart';
import 'package:kanji_memory_hint/quiz/quiz_result.dart';
import 'package:kanji_memory_hint/quiz/repo.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:kanji_memory_hint/scoring/model.dart';


class Quiz extends StatefulWidget {
  const Quiz({Key? key, required this.mode, required this.chapter}) : super(key: key);

  final GAME_MODE mode;
  final int chapter;
  static const route = "/quiz";
  static const name = "Quiz";

  Future<List> _getQuizQuestionSet() async {
    return QuizQuestionMaker.makeQuestionSet(3, chapter, mode);
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
  bool initial = true;
  bool isMcReady = false;
  bool isJumbleReady = false;

  QuizScore multipleChoiceScore = QuizScore(correct: 0, miss: 0, correctlyAnsweredKanji: []);
  QuizScore jumbleScore = QuizScore(correct: 0, miss: 0, correctlyAnsweredKanji: []); 

  late QuizReport report;

  late final Countdown _countdown;

  @override
  void initState() {
    super.initState();
    quizQuestionSet = widget._getQuizQuestionSet();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // _countdown.start();
    });
  }

  void postQuizHook() {
    report = QuizReport(
      multiple: multipleChoiceScore, 
      jumble: jumbleScore,
      chapter: widget.chapter,
      gains: GameResult(expGained: 100, pointsGained: 100)
    );

    MasteryHandler.addMasteryFromQuiz(report);
    QuizQuestHandler.checkForQuests(report);
    initial = false;
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

  void _handleMultipleChoiceSubmit(int correct, int wrong, List<List<int>> correctKanjis) {
    setState(() {
      multipleChoiceScore = QuizScore(
        correct: correct, 
        miss: wrong, 
        correctlyAnsweredKanji: correctKanjis
      );

      mulchoiceCorrect = correct;
      mulchoiceWrong = wrong;

      if(_countdown.isDone) {
        gameIndex = 2;
      } else {
        gameIndex = 1;
      }
      isMcReady = true;
    });
  }

  void _handleJumbleSubmit(int correct, int misses, List<List<int>> correctKanjis) {
    setState(() {
      jumbleScore = QuizScore(
        correct: correct, 
        miss: misses, 
        correctlyAnsweredKanji: correctKanjis
      );

      jumbleCorrect = correct;
      jumbleMisses = misses;
      isOver = true;
      gameIndex = 2;
      isJumbleReady = true;
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
    List<QuizQuestionSet> mcQuestionSets = items[0];
    List<JumbleQuizQuestionSet> jumbleQuestionSets = items[1];


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
                child: MultipleChoiceQuizGame(
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
                    result: multipleChoiceScore, 
                    goHere: _goMultipleChoice
                  ), 
                  jumble: QuizGameParam(
                    result: jumbleScore,
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

  Widget _buildQuiz(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(isOver && initial && (isMcReady && isJumbleReady)) {
        postQuizHook();
      }
     });
    return PracticeBackground(
      child: _buildQuiz(context)
    );
  }
}



class _JumbleGame extends StatefulWidget {

  final GAME_MODE mode;
  final List<JumbleQuizQuestionSet> questionSets;
  final bool quizOver;
  final Function(int correct, int misses, List<List<int>> score) onSubmit;

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
      child: Column(
        children: [
          JumbleQuizRound(
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

  Widget _build(BuildContext context, List<JumbleQuizQuestionSet> items) {
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