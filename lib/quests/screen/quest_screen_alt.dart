import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kanji_memory_hint/audio_repository/audio.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/level_progress_bar.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/database/user_point.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/kanji-list/kanji_menu.dart';
import 'package:kanji_memory_hint/levelling/levels.dart';
import 'package:kanji_memory_hint/quests/mastery.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/quests/quiz_quest.dart';
import 'package:kanji_memory_hint/quests/screen/gold.dart';
import 'package:kanji_memory_hint/quests/screen/layout.dart';
import 'package:kanji_memory_hint/quests/screen/quest_obj.dart';
import 'package:kanji_memory_hint/reward/reward_screen.dart';
import 'package:kanji_memory_hint/theme.dart';

class QuestScreenAlt extends StatefulWidget {
  
  static const route = "/quests";
  static const name = "Quest Screen";
  
  @override
  State<StatefulWidget> createState() => _QuestScreenState();
}



class _QuestScreenState extends State<QuestScreenAlt> {

  @override
  Widget build(BuildContext context) {
    AudioManager.music.menu();
    final size = MediaQuery.of(context).size;
    return MenuBackground(
      child: QuestScreenLayoutAlt(
        progressWidget:  Column(
          children: [
            EmptyFlex(flex: 1),
            Flexible(flex: 4, child: _ProgressContainer(),),
            EmptyFlex(flex: 6)
          ]
        ),
        questWidget: QuestMenuWidget(),
        footer: Column(
          children: [
            EmptyFlex(flex: 1),
            Flexible(
              flex: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 1,
                    child: SelectButton(
                      title: "Kanji List",
                      iconPath: AppIcons.list,
                      width: size.width*0.35,
                      onTap: (){
                        Navigator.of(context).pushNamed(KanjiList.route);
                      },
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: SelectButton(
                      title: "Rewards",
                      iconPath: AppIcons.currency,
                      width: size.width*0.35,
                      onTap: (){
                        Navigator.of(context).pushNamed(RewardScreen.route);
                      },
                    ),
                  )
                ]
              ),
            ),
            EmptyFlex(flex: 2)
          ]
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(flex: 1, child: SizedBox()),
                  Flexible(flex: 1, child: SizedBox()),
                  Flexible(
                    flex: 1, 
                    child: Container(
                      height: size.width*.1,
                      width: size.width*.2,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2),
                        color: AppColors.primary
                      ),
                      child: GoldWidget(gold: gold,)
                    )
                  )
                ]
              )
            ),
            Flexible(
              flex: 11,
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
                    Flexible(
                      flex: 16, 
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
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width*.8,
      height: size.height*.3,
      child: FutureBuilder(
      future: Levels.current(),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if(snapshot.hasData) {
          final level = snapshot.data![0];
          final remaining = snapshot.data![1];
          final toNextLevel = Levels.next(level);
          return Container(
            width: size.width*.8,
            height: size.width*.1,
            padding: EdgeInsets.fromLTRB(
              10,
              10,
              10,
              0
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              border: Border.all(width: 2)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2, 
                  child: Text(
                    "Level "+ level.toString(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                EmptyFlex(flex: 1),
                Flexible(
                  flex: 2, 
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        child: LevelProgressBar(upperbound: toNextLevel ?? remaining, current: remaining)
                      );
                    }
                  )
                )
              ]
            ),
          );
        } else {
          return LoadingScreen();
        }
      }
      )
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

  Widget _button(BuildContext context, int buttonIndex, String title, BorderRadius radius) {
    final noDecorationButton = TextButton.styleFrom(
      side: BorderSide.none,
      backgroundColor: Colors.transparent
    );
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight,
          width: size.width,
          decoration: BoxDecoration(
            color: buttonIndex == selected ? AppColors.primary : AppColors.cream,
            borderRadius: radius
          ),
          child: TextButton(
            onPressed: () {
              setState(() {
                selected = buttonIndex;
              });
              widget.onTap(buttonIndex);
            }, 
            child: _title(title, selected == buttonIndex),
            style: noDecorationButton 
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final noDecorationButton = TextButton.styleFrom(
      side: BorderSide.none,
    );

    return Container(
      height: size.height*0.075,
      width: size.width,
      child: Container(
        width: size.width*0.8,
        color: AppColors.cream,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: _button(
                context, 
                0, 
                "Kanji",
                BorderRadius.only(topRight: Radius.circular(10))
              )
            ),
            Flexible(
              child: _button(
                context, 
                1, 
                "Practice",
                BorderRadius.only(
                  topLeft: Radius.circular(10), 
                  topRight: Radius.circular(10)
                )
              )
            ),
            Flexible(
              child: _button(
                context, 
                2, 
                "Quiz",
                BorderRadius.only(
                  topLeft: Radius.circular(10),
                  
                )
              )
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
          title: Text(quest.toString()),
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
            title: Text(quest.toString()),
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
              quest.toString()
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
