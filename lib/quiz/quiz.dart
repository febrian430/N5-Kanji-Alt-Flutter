import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/backgrounds/practice_background.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/countdown.dart';
import 'package:kanji_memory_hint/images.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/menu_screens/quiz_screen.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/quests/mastery.dart';
import 'package:kanji_memory_hint/quests/quiz_quest.dart';
import 'package:kanji_memory_hint/quiz/footer_nav.dart';
import 'package:kanji_memory_hint/quiz/jumble.dart';
import 'package:kanji_memory_hint/quiz/multiple_choice.dart';
import 'package:kanji_memory_hint/quiz/quiz_result.dart';
import 'package:kanji_memory_hint/quiz/repo.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/scoring/report.dart';


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
  
  late final _Screen mc = _Screen(
    "Quiz", "クイズ",
    dialog: GuideDialog(
      game: MultipleChoiceGame.name,
      description: "Your classic kanji multiple choice game. Choose the correct kanji based on the image",
      guideImage: AppImages.guideMultipleChoice,
      onClose: onContinue,
    ),
    onDialogOpen: onPause
  );

  late final _Screen jumble = _Screen(
    "Quiz", "クイズ",
    dialog: GuideDialog(
      game: JumbleGame.name,
      description: "Select the kanji based on the image in order",
      guideImage: AppImages.guideJumble,
      onClose: onContinue,
    ),
    onDialogOpen: onPause
  );
  late final _Screen result = _Screen("Result", "結果");

  late Map<int, _Screen> mapping = {
    0: mc,
    1: jumble,
    2: result
  };

  int secondsLeft = 7200;
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

  bool restart = false;

  QuizScore multipleChoiceScore = QuizScore(correct: 0, miss: 0, correctlyAnsweredKanji: []);
  QuizScore jumbleScore = QuizScore(correct: 0, miss: 0, correctlyAnsweredKanji: []); 

  late QuizReport report;

  late final Countdown _countdown;

  void onRestart(){
    var arg = PracticeGameArguments(
      selectedGame: Quiz.route, 
      gameType: GAME_TYPE.QUIZ
    );
    arg.chapter = widget.chapter;
    Navigator.popAndPushNamed(context, Quiz.route, 
      arguments: arg
    );
  }

  @override
  void initState() {
    super.initState();
    quizQuestionSet = widget._getQuizQuestionSet();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _countdown.start();
    });
  }

  @override
  void dispose() {
    _countdown.stop();
    super.dispose();
  }

  void postQuizHook() async {
    report = QuizReport(
      multiple: multipleChoiceScore, 
      jumble: jumbleScore,
      chapter: widget.chapter,
      gains: GameResult(expGained: 100, pointsGained: 100)
    );

    Future.delayed(Duration(milliseconds: 200), () async {
      print("mulchoice during quiz ${report.multiple.correctlyAnsweredKanji.join(",")}");
      print("jumble during quiz ${report.jumble.correctlyAnsweredKanji.join(",")}");
      await MasteryHandler.addMasteryFromQuiz(report);
      await QuizQuestHandler.checkForQuests(report);
    });

    initial = false;
    _countdown.pause();
    gameIndex = 2;
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
  
  Widget _build(BuildContext context, List items) {
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
                  restartSource: restart,
                )
              ),
              JumbleQuizGame(
                mode: widget.mode,
                questionSets: jumbleQuestionSets,
                quizOver: isOver,
                onSubmit: _handleJumbleSubmit,
                restartSource: restart,
              ),
              QuizResult(
                  onRestart: onRestart,
                  countdown: _countdown,
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
      ]
    );
  }

  Widget _buildQuiz(BuildContext context) {
    return FutureBuilder(
          future: quizQuestionSet,
          builder: (context, AsyncSnapshot<List> snapshot) {
            if(snapshot.hasData) {
              return _build(context, snapshot.data!);
            } else {
              return LoadingScreen();
            }
          }
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(isOver && initial && (isMcReady && isJumbleReady)) {
        postQuizHook();
      }
     });

    final screen = mapping[gameIndex];

    return QuizScreen(
      title: screen!.name,
      japanese: screen.japanese,
      onContinue: onContinue,
      onPause: onPause,
      onRestart: onRestart,
      game: _buildQuiz(context),
      guide: screen.dialog,
      onGuideOpen: screen.onDialogOpen,
      isOver: isOver,
      footerWhenOver: Row(
        children: [
          Expanded(
            flex: 1,
            child: _FooterNav(
              title: "Multiple Choice",
              go: _goMultipleChoice,
            )
          ),
          Expanded(
            flex: 1,
            child: _FooterNav(
              title: "Jumble",
              go: _goJumble,
            )
          ),
          Expanded(
            flex: 1,
            child: _FooterNav(
              title:"Result",
              go: _goQuizResult,
            )
          ),
        ],
      )
    );
  }

  onContinue() {
    _countdown.start();
  }

  onPause() {
    _countdown.pause();
  }
}

class _Screen {
  final String name;
  final String japanese;
  final GuideDialog? dialog;
  final Function()? onDialogOpen;

  _Screen(this.name, this.japanese, {this.dialog, this.onDialogOpen});
}

class _FooterNav extends StatelessWidget{
  final String title;
  final Function() go;

  const _FooterNav({Key? key, required this.title, required this.go}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        side: BorderSide.none,
      ),
      onPressed: go,
      child: Container(
        alignment: Alignment.center,
        height: 100, 
        child: Text(title, 
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black
          ),
        ),
      )
    );
  }

}