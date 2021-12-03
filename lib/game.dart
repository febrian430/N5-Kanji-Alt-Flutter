import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/const.dart';

abstract class Game extends StatefulWidget {
  const Game({Key? key, required this.mode, required this.chapter}) : super(key: key);

  final GAME_MODE mode;
  final int chapter;

  @override
  State<StatefulWidget> createState();

}

abstract class GameState<T extends Game> extends State<T> {

  @override
  Widget build(BuildContext context);
}

class MockGame extends Game {
  MockGame(GAME_MODE mode, int chapter) : super(mode: mode, chapter: chapter);

  static const routeName = "/mock";

  @override
  State<StatefulWidget> createState() => MockGameState();
  
}

class MockGameState extends GameState {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "BREAK" + widget.mode.toString() + "DOWN" + widget.chapter.toString()
      ),);
  }
}