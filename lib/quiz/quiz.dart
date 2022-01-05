import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/backgrounds/practice_background.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/countdown.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/quests/mastery.dart';
import 'package:kanji_memory_hint/quests/quiz_quest.dart';
import 'package:kanji_memory_hint/quiz/footer_nav.dart';
import 'package:kanji_memory_hint/quiz/jumble.dart';
import 'package:kanji_memory_hint/quiz/multiple_choice.dart';
import 'package:kanji_memory_hint/quiz/quiz_result.dart';
import 'package:kanji_memory_hint/quiz/repo.dart';
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
              JumbleQuizGame(
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
