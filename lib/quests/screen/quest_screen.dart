import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/backgrounds/quest_background.dart';
import 'package:kanji_memory_hint/components/buttons/back_button.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/menu_screens/quest_screen_layout.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';
import 'package:kanji_memory_hint/quests/mastery.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/quests/quiz_quest.dart';
import 'package:kanji_memory_hint/quests/screen/quest_obj.dart';
import 'package:kanji_memory_hint/theme.dart';

class QuestScreen extends StatefulWidget {
  
  static const route = "/quests";
  static const name = "Quest Screen";
  
  @override
  State<StatefulWidget> createState() => _QuestScreenState();
}



class _QuestScreenState extends State<QuestScreen> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MenuBackground(
      child: QuestScreenLayout(
        content: Column(
            children: [
              Expanded(
                flex: 6,
                child: _ProgressContainer(),
              ),
              Expanded(
                flex: 6,
                child: QuestMenuWidget()
              )
            ],
        ), 
        footer: TextButton(
          child: Text("Trade reward"),
          onPressed: (){},
        )
      )
    );
  }
}

class QuestMenuWidget extends StatefulWidget {
  const QuestMenuWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuestWidgetState();

}

class _QuestWidgetState extends State<QuestMenuWidget> {
  int questIndex = 1;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height*0.4,
      decoration: BoxDecoration(
        color: AppColors.primary
      ),
      child: Column(
        children: [
          Flexible(
            flex: 3, 
            child: _SelectBar(
              onTap: (int index) {
                setState(() {
                  questIndex = index;
                });
              }
            ),
          ),
          Expanded(flex: 8, child: _QuestList(index: questIndex,))
        ],
      )
    );
  }

}

class _ProgressContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
        width: size.width,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage(APP_IMAGE_FOLDER+'main_menu.png'),
            fit: BoxFit.fill
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
                HexColor.fromHex("f9e7b1"),
                HexColor.fromHex("f9e7b1"),
                HexColor.fromHex("f8b444")
            ],
            tileMode: TileMode.decal, // repeats the gradient over the canvas
          )
        ),
        child: Text("Test")
    );
  }
}

class _SelectBar extends StatefulWidget {
  final Function(int index) onTap;
  const _SelectBar({Key? key, required this.onTap}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectBarState();

  
}

class _SelectBarState extends State<_SelectBar> {
  int selected = 0;

  Widget _title(String title, bool selected) {
    return Text(
      title,
      style: TextStyle(
        shadows: [
          Shadow(
              color: Colors.black,
              offset: Offset(0, -4))
        ],
        color: Colors.transparent,
        decoration: selected ? TextDecoration.underline : null,
        decorationThickness: selected ? 3 : null,
        decorationColor: selected ? Colors.blue : null,
        fontWeight: !selected ? FontWeight.normal : null
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final noDecorationButton = TextButton.styleFrom(
      side: BorderSide.none
    );

    return Container(
      height: size.height*0.1,
      width: size.width,
      child: Container(
        width: size.width*0.8,
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                setState(() {
                  selected = 0;
                });
                widget.onTap(0);
              }, 
              child: _title("Mastery", selected == 0),
              style: noDecorationButton,
            ),
          ),
          Expanded(child: TextButton(
            onPressed: () {
              setState(() {
                  selected = 1;
              });
              widget.onTap(1);
            }, 
            child: _title("Practice", selected == 1),
            style: noDecorationButton
            ),
          ),
          Expanded(child: TextButton(
            onPressed: () {
              setState(() {
                  selected = 2;
              });
              widget.onTap(2);
            }, 
            child: _title("Quiz", selected == 2),
            style: noDecorationButton
            ),
          )
        ],
        )
      ),
    );
  }
}

class _QuestList extends StatelessWidget {
  const _QuestList({Key? key, this.index = 0}) : super(key: key);
  
  final int index;

  Widget _mastery() {
    return FutureBuilder(
      future: MasteryHandler.quests(),
      builder: (BuildContext context,
          AsyncSnapshot<List<MasteryQuest>> snapshot) {
        if (snapshot.hasData) {
          return _MasteryQuestList(quests: snapshot.data!);
        } else {
          return const Text("Loading...");
        }
      },
    );
  }

  Widget _practiceList() {
    return FutureBuilder(
      future: PracticeQuestHandler.quests(),
      builder: (BuildContext context, AsyncSnapshot<List<PracticeQuest>> snapshot){
        if(snapshot.hasData) {
          return _PracticeQuestList(quests: snapshot.data!);
        }else {
          return const Text("Loading...");
        }
      },
    );
  }

  Widget _quizList() {
    return FutureBuilder(
      future: QuizQuestHandler.quests(),
      builder: (BuildContext context, AsyncSnapshot<List<QuizQuest>> snapshot){
        if(snapshot.hasData) {
          return _QuizQuestList(quests: snapshot.data!);
        }else {
          return const Text("Loading...");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: Container(
        width: size.width*0.85, 
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
          )
        ),
        child: IndexedStack(
          index: index,
          children: [
            _mastery(),
            _practiceList(),
            _quizList(),
          ],
        ),
      )
    );
  }
}

class _PracticeQuestList extends StatelessWidget {

  final List<PracticeQuest> quests;

  const _PracticeQuestList({Key? key, required this.quests}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: quests.length,
      itemBuilder: (BuildContext context, int index) {
        final quest = quests[index];
        return QuestWidget(
          title: Text('Play ${quest.game} ${quest.mode == null ? '' :  quest.mode!.name + ' mode'}  with topic ${quest.chapter} ${quest.requiresPerfect == 1 ? "perfectly" : ""}'),
          count: quest.count,
          total: quest.total,
          status: quest.status,
          claimable: quest.count >= quest.total,
          onClaim: quest.claim,
          goldReward: quest.goldReward,
        );
      }
    );

  }
}

class _QuizQuestList extends StatelessWidget {

  final List<QuizQuest> quests;

  const _QuizQuestList({Key? key, required this.quests}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: quests.length,
        itemBuilder: (BuildContext context, int index) {
          final quest = quests[index];
          return QuestWidget(
            title: Text('Do ${quest.game} with topic ${quest.chapter}'),
            count: quest.count,
            total: quest.total,
            status: quest.status,
            onClaim: quest.claim,
            claimable: quest.count >= quest.total,
            goldReward: quest.goldReward,
          );
        }
    );

  }
}

class _MasteryQuestList extends StatelessWidget {

  final List<MasteryQuest> quests;

  const _MasteryQuestList({Key? key, required this.quests}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: quests.length,
        itemBuilder: (BuildContext context, int index) {
          final quest = quests[index];
          return QuestWidget(
            title: Text(
              "Master ${quest.total} kanjis"
            ),
            count: quest.count,
            total: quest.total,
            claimable: quest.count >= quest.total,
            status: quest.status,
            onClaim: quest.claim,
            goldReward: quest.goldReward,
          );
        }
    );

  }
}
