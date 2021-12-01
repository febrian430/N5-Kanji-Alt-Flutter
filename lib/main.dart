import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/home.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/kanji-list/menu.dart';
import 'package:kanji_memory_hint/menu_screens/game_select.dart';
import 'package:kanji_memory_hint/mix-match/game.dart';
import 'package:kanji_memory_hint/pick-drop/game.dart';

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
      initialRoute: '/game/jumble',
      routes: {
        '/': (context) => const Home(),
        '/list': (context) => Menu(),
        '/game': (context) => GameSelect(),
        '/game/multiple-choice': (context) => MultipleChoiceGame(),
        '/game/pick-drop': (context) => PickDrop(),
        '/game/mix-match': (context) => MixMatchGame(mode: GAME_MODE.reading),
        '/game/jumble': (context) => JumbleGame(mode: GAME_MODE.imageMeaning, chapter: 1),

      }
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}