import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/game.dart';
import 'package:kanji_memory_hint/kanji-list/view.dart';
import 'package:kanji_memory_hint/menu_screens/chapter_select.dart';
import 'package:kanji_memory_hint/menu_screens/mode_select.dart';
import 'package:kanji_memory_hint/notification/notifier.dart';
import 'package:kanji_memory_hint/result_screen/practice.dart';
import 'package:kanji_memory_hint/menu_screens/start_select.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/kanji-list/kanji_menu.dart';
import 'package:kanji_memory_hint/menu_screens/game_select.dart';
import 'package:kanji_memory_hint/mix-match/game.dart';
import 'package:kanji_memory_hint/pick-drop/game.dart';
import 'package:kanji_memory_hint/quests/screen/quest_screen.dart';
import 'package:kanji_memory_hint/quiz/quiz.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/test.dart';
import 'package:kanji_memory_hint/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifier.initialize();
  await SQLRepo.open();

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.

  @override
  State<StatefulWidget> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return MaterialApp(
      title: 'N5 Kanji',
      theme: ThemeData( 
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        
        scaffoldBackgroundColor: Colors.transparent,
        // primarySwatch: Colors.blue,
        // primaryColor: Colors.black,
        backgroundColor: Colors.white,

        dialogTheme: DialogTheme(
          backgroundColor: AppColors.primary,
        ),
        textTheme: TextTheme(
          button: TextStyle(
            color: Colors.black,
            
            fontSize: 18
          )
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            side: const BorderSide(width: 2, color: Colors.black)
          )
        )
      ),
      initialRoute: '/',
      routes: { 
        '/': (context) => const Home(),
        '/list': (context) => KanjiMenu(),
        '/list/view': (context) => KanjiScreen(),
        '/game': (context) => GameSelect(),
        '/start-select': (context) => StartSelect(),
        '/chapter-select': (context) => ChapterSelect(),
        '/mode-select': (context) => const ModeSelect(),
        '/result': (context) => ResultScreen(),
        '/quests': (context) => QuestScreen(),
        '/test': (context) => Test()


        // '/result': (context) => ResultScreen(wrongCount: 10)

        // '/game/multiple-choice': (context) => MultipleChoiceGame(chapter: 1, mode: GAME_MODE.imageMeaning),
        // '/game/pick-drop': (context) => PickDrop(),
        // '/game/mix-match': (context) => MixMatchGame(),
        // '/game/jumble': (context) => JumbleGame(mode: GAME_MODE.imageMeaning, chapter: 1),

      },
      onGenerateRoute: (settings) {

        switch (settings.name) {
          case MockGame.routeName:
            final args = settings.arguments as PracticeGameArguments;

            return MaterialPageRoute(builder: (context) {
              return MockGame(args.mode, args.chapter);
            });

          case MultipleChoiceGame.route:
            final args = settings.arguments as PracticeGameArguments;

            return MaterialPageRoute(builder: (context) {
                return MultipleChoiceGame(mode: args.mode, chapter: args.chapter);
            });

          case MixMatchGame.route:
            final args = settings.arguments as PracticeGameArguments;

            return MaterialPageRoute(builder: (context) {
                return MixMatchGame(mode: args.mode, chapter: args.chapter);
            });

          case JumbleGame.route:
            final args = settings.arguments as PracticeGameArguments;

            return MaterialPageRoute(builder: (context) {
                return JumbleGame(mode: args.mode, chapter: args.chapter);
            });
          
          case PickDrop.route:
            final args = settings.arguments as PracticeGameArguments;

            return MaterialPageRoute(builder: (context) {
                return PickDrop(mode: GAME_MODE.imageMeaning, chapter: args.chapter);
            });
          
          case Quiz.route:
            final args = settings.arguments as PracticeGameArguments;

            return MaterialPageRoute(builder: (context) {
              return Quiz(mode: GAME_MODE.imageMeaning, chapter: args.chapter);
            });
          default:
            
        }
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuBackground(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SelectButton(
                onTap: () {
                  Navigator.pushNamed(context, '/list');
                  
                },
                title: 'List',
              ),
            ),
            Center(
              child: SelectButton(
                onTap: () {
                  Navigator.pushNamed(context, StartSelect.route);
                  
                },
                title: 'Start',
              ),
            ),
            Center(
              child: SelectButton(
                onTap: () {
                  Navigator.pushNamed(context, '/quests');
                  
                },
                title: 'Quests',
              ),
            ),
            Center(
              child: SelectButton(
                onTap: () {
                  Navigator.pushNamed(context, '/test');
                  
                },
                title: 'test',
              ),
            ),
            Center(
              child: SelectButton(
                onTap: () async {
                  await Notifier.createNotifier();
                },
                title: 'Notify',
              ),
            )
          ]
        )
      )
    );
  }
}