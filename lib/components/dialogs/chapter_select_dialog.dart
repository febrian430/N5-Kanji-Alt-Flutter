import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/icon_button.dart';
import 'package:kanji_memory_hint/components/containers/double_border_container.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/kanji.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/mix-match/game.dart';
import 'package:kanji_memory_hint/pick-drop/game.dart';
import 'package:kanji_memory_hint/quiz/quiz.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/test.dart';
import 'package:kanji_memory_hint/theme.dart';

class ChapterSelectDialog extends StatelessWidget {
  final PracticeGameArguments param;
  final int chapter;

  const ChapterSelectDialog({Key? key, required this.param, required this.chapter}) : super(key: key);

  String _getGameName(String selectedGame) {
    switch (selectedGame) {
      case MixMatchGame.route:
        return MixMatchGame.name;
      case JumbleGame.route:
        return JumbleGame.name;
      case PickDrop.route:
        return PickDrop.name;
      default:
        return Quiz.name;
    }
  }


  Widget _header(BuildContext context) {
    final gameName = _getGameName(param.selectedGame);
    return Column(
      children: [
        Text(param.gameType == GAME_TYPE.PRACTICE ? "Practice" : "Quiz"),
        Text(gameName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ]
    );
  }
  Widget _kanji(BuildContext context, Kanji kanji) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2)
      ),
      child: Center(child: Text(kanji.rune, style: TextStyle(fontSize: 20),)),
    );
  }

  Widget _topic(BuildContext context, List<Kanji> kanjis) {
    final size = MediaQuery.of(context).size;
    
    return Column(
      children: [
        Flexible(
          flex: 2,
          child: Container(
            height: 50,
            width: size.width*.40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(width: 2)
            ),
            child: Text("Topic $chapter", 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
          )
        ),

        Flexible(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15
            ),
            child: GridView.count(
              crossAxisCount: 5,
              childAspectRatio: 1,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              children: kanjis.map((kanji) => _kanji(context, kanji)).toList(),
            ),
          )
        )
      ],
    );
  }

  Widget _buttons(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2, 
          child: Text(
            "Confirm?", 
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Expanded(flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              EmptyFlex(flex: 2),
              Flexible(
                flex: 4,
                child: AspectRatio(
                  aspectRatio: 6/4,
                  child: AppIconButton(
                    onTap: (){
                      param.chapter = chapter;
                      Navigator.of(context).pushReplacementNamed(param.selectedGame,
                        arguments: param  
                      );
                    }, 
                    iconPath: AppIcons.yes, 
                    height: 100, 
                    width: 400, 
                    backgroundColor: AppColors.correct
                  ),
                )
              ),
              EmptyFlex(flex: 1),
              Flexible(
                flex: 4,
                child: AspectRatio(
                  aspectRatio: 6/4,
                  child: AppIconButton(
                    onTap: (){
                      Navigator.of(context).pop();
                    }, 
                    iconPath: AppIcons.no, 
                    height: 125, 
                    width: 300, 
                    backgroundColor: AppColors.primary
                  )
                )
              ),
              EmptyFlex(flex: 2),

            ],
          )
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      child: TwoBorderContainer(
        width: size.width*.75,
        height: size.height*.47,
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
          future: SQLRepo.kanjis.byChapter(chapter),
          builder: (context, AsyncSnapshot<List<Kanji>> snapshot){
            if(snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: _header(context)
                  ),
                  Flexible(
                    flex: 5, 
                    child: _topic(context, snapshot.data!),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buttons(context)
                  )
                ],
              );
            } else {
              return LoadingScreen();
            }
          },
        )
        
        
      ),
    );
  }


  
}