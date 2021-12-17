import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game.dart';
import 'package:kanji_memory_hint/kanji-list/view.dart';
import 'package:kanji_memory_hint/menu_screens/chapter_select.dart';
import 'package:kanji_memory_hint/menu_screens/mode_select.dart';
import 'package:kanji_memory_hint/menu_screens/result_screen.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/kanji-list/menu.dart';
import 'package:kanji_memory_hint/menu_screens/game_select.dart';
import 'package:kanji_memory_hint/mix-match/game.dart';
import 'package:kanji_memory_hint/pick-drop/game.dart';
import 'package:kanji_memory_hint/quests/quest_screen.dart';
import 'package:kanji_memory_hint/quiz/quiz.dart';
import 'package:kanji_memory_hint/route_param.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        backgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: { 
        '/': (context) => const Home(),
        '/list': (context) => Menu(),
        '/list/view': (context) => KanjiScreen(),
        '/game': (context) => GameSelect(),
        '/chapter-select': (context) => const ChapterSelect(),
        '/mode-select': (context) => const ModeSelect(),
        '/result': (context) => ResultScreen(),
        '/quests': (context) => QuestScreen()

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
                return PickDrop(mode: args.mode, chapter: args.chapter);
            });
          
          case Quiz.route:
            final args = settings.arguments as PracticeGameArguments;

            return MaterialPageRoute(builder: (context) {
              return Quiz(mode: args.mode, chapter: args.chapter);
            });
          // case ResultScreen.route:
          //   final args = settings.arguments as ResultParam;

          //   return MaterialPageRoute(builder: (context) {
          //       return JumbleGame(mode: args.mode, chapter: args.chapter);
          //   });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              // Within the `Home` widget
              onPressed: () {
                // Navigate to the second screen using a named route.
                Navigator.pushNamed(context, '/list');
                
              },
              child: const Text('List'),
            ),
          ),
          Center(
            child: ElevatedButton(
              // Within the `Home` widget
              onPressed: () {
                // Navigate to the second screen using a named route.
                Navigator.pushNamed(context, '/game');
                
              },
              child: const Text('Start'),
            ),
          ),
          Center(
            child: ElevatedButton(
              // Within the `Home` widget
              onPressed: () {
                // Navigate to the second screen using a named route.
                Navigator.pushNamed(context, '/quests');
                
              },
              child: const Text('Quests'),
            ),
          ),
      ]
    )
    );
  }
}