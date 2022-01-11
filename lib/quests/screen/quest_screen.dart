import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/progress_bar.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/database/user_point.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/levelling/levels.dart';
import 'package:kanji_memory_hint/menu_screens/quest_screen_layout.dart';
import 'package:kanji_memory_hint/quests/mastery.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/quests/quiz_quest.dart';
import 'package:kanji_memory_hint/quests/screen/quest_obj.dart';
import 'package:kanji_memory_hint/reward/reward_screen.dart';
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: _ProgressContainer(),
            ),
            Expanded(
              flex: 11,
              child: QuestMenuWidget()
            )
          ],
        ), 
        footer: TextButton(
          child: Text("Trade reward"),
          onPressed: (){
            Navigator.of(context).pushNamed(RewardScreen.route);
          },
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
  int questIndex = 0;
  bool loaded = false;
  int gold = 0;
  var points;

  void onQuestClaim(int goldClaim) {
    setState(() {
      print("called");
      gold+=goldClaim;
    });
  }

  Widget _gold(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: SizedBox()),
        Expanded(flex: 1, child: SizedBox()),
        Expanded(
          flex: 1, 
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 24
            ),
            padding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 5
            ),
            decoration: BoxDecoration(
              border: Border.all(width: 2),
              color: AppColors.primary,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    gold.toString(), 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),  
                  )
                ),
                Flexible(
                  flex: 1,
                  child: Center(child: Image.asset(AppIcons.currency))
                )
              ],
            ),
          )
        ),
      ]
    );
  }

  @override
  void initState() {
    super.initState();
    points = SQLRepo.userPoints.get();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FutureBuilder(
      future: points,
      builder: (context, AsyncSnapshot<UserPoint> snapshot){
        if(snapshot.hasData && !loaded) {
          gold = snapshot.data!.gold;
          loaded=true;
        }
        return Column(
          children: [
            Flexible(
              flex: 2,
              child: _gold(context)
            ),
            Flexible(
              flex: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary
                ),
                child: Column(
                  children: [
                    Flexible(
                      flex: 3, 
                      child: _SelectBar(
                        index: questIndex,
                        onTap: (int index) {
                          setState(() {
                            questIndex = index;
                          });
                        }
                      ),
                    ),
                    Expanded(
                      flex: 8, 
                      child: _QuestList(
                        onClaimQuest: onQuestClaim,
                        index: questIndex,
                      )
                    )
                  ],
                )
              )
            )
          ]
        );
      }
      
    );
        
  }

}

class _ProgressContainer extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ProgressContainerState();
}

class _ProgressContainerState extends State<_ProgressContainer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Levels.current(),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if(snapshot.hasData) {
          final level = snapshot.data![0];
          final remaining = snapshot.data![1];
          final toNextLevel = Levels.next(level);
          return Column(
            children: [
              Text(level.toString(), style: TextStyle(fontSize: 50),),
              ProgressBar(
                from: remaining, 
                gain: 0, 
                levelupReq: toNextLevel ?? remaining, 
                nextLevel: 999, 
                onLevelup: (){
                  print("huh");
                }
              ),
              Text('${remaining.toString()}/${toNextLevel.toString()}'),
            ],
          );
        } else {
          return LoadingScreen();
        }
      }
    );
  }

}

class _SelectBar extends StatefulWidget {
  final Function(int index) onTap;
  final int index;
  const _SelectBar({Key? key, required this.onTap, this.index = 0}) : super(key: key);

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
  
  const _QuestList({Key? key, this.index = 0, required this.onClaimQuest}) : super(key: key);
  
  final Function(int) onClaimQuest;
  final int index;

  Widget _mastery() {
    return FutureBuilder(
      future: MasteryHandler.quests(),
      builder: (BuildContext context,
          AsyncSnapshot<List<MasteryQuest>> snapshot) {
        if (snapshot.hasData) {
          return _MasteryQuestList(quests: snapshot.data!, onClaimQuest: onClaimQuest,);
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
          return _PracticeQuestList(quests: snapshot.data!, onClaimQuest: onClaimQuest,);
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
          return _QuizQuestList(quests: snapshot.data!, onClaimQuest: onClaimQuest,);
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
  final Function(int) onClaimQuest;

  const _PracticeQuestList({Key? key, required this.quests, required this.onClaimQuest}) : super(key: key);

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
          onClaim: (){
            quest.claim();
            onClaimQuest(quest.goldReward);
          },
          goldReward: quest.goldReward,
        );
      }
    );

  }
}

class _QuizQuestList extends StatelessWidget {

  final List<QuizQuest> quests;
  final Function(int) onClaimQuest;

  const _QuizQuestList({Key? key, required this.quests, required this.onClaimQuest}) : super(key: key);

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
            onClaim: (){
              quest.claim();
              onClaimQuest(quest.goldReward);
            },
            claimable: quest.count >= quest.total,
            goldReward: quest.goldReward,
          );
        }
    );

  }
}

class _MasteryQuestList extends StatelessWidget {

  final List<MasteryQuest> quests;
  final Function(int) onClaimQuest;

  const _MasteryQuestList({Key? key, required this.quests, required this.onClaimQuest}) : super(key: key);

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
            onClaim: (){
              quest.claim();
              onClaimQuest(quest.goldReward);
            },
            goldReward: quest.goldReward,
          );
        }
    );

  }
}
