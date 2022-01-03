import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/quests/quiz_quest.dart';

class QuestScreen extends StatefulWidget {
  
  static const route = "/quests";
  static const name = "Quest Screen";
  
  @override
  State<StatefulWidget> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {

  int listIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Center(child: _ProgressContainer()),
              _SelectBar(onTap: (int index) {
                setState(() {
                  listIndex = index;
                });
              }),
              _QuestList(index: listIndex,)
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height*0.125,
      width: size.width*0.8,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(child: Text("Level"),),
          Center(child: Text("Progress bar here"),)
        ],
      ),
    );
  }
}

class _SelectBar extends StatelessWidget {
  final Function(int index) onTap;
  const _SelectBar({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height*0.1,
      width: size.width*0.8,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              onTap(0);
            }, 
            child: Text("Mastery")
          ),
          TextButton(
            onPressed: () {
              onTap(1);
            }, 
            child: Text("Practice")
          ),
          TextButton(
            onPressed: () {
              onTap(2);
            }, 
            child: Text("Quiz")
          ),
        ],
      ),
    );
  }
}

class _QuestList extends StatelessWidget {
  const _QuestList({Key? key, this.index = 0}) : super(key: key);
  
  final int index;

  Widget _mastery() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return SizedBox(child: Text("Mastery " + index.toString()), height: 150);
      }
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

    return Container(
      height: size.height*0.6,
      width: size.width*0.8,
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
    );
  }
}

class _PracticeQuestList extends StatelessWidget {

  final List<PracticeQuest> quests;

  const _PracticeQuestList({Key? key, required this.quests}) : super(key: key);
  
  Widget questWidget(PracticeQuest quest) {
    return SizedBox(
        height: 150,
        child: Row( 
          children: [
            Flexible(flex: 8, child: Text('Do ${quest.game} ${quest.mode == null ? '' :  quest.mode!.name + ' mode'}  with topic ${quest.chapter} ${quest.requiresPerfect == 1 ? "perfectly" : ""}')),
            Flexible(
              flex: 2, 
              child: Column(
                children: [
                  Visibility(
                    visible: quest.count >= quest.total, 
                    child: Flexible(
                      flex: 6, 
                      child: TextButton(
                        child: Center(child: quest.status == QUEST_STATUS.CLAIMED ? Text("Claimed") : Text("Claim")),
                        onPressed: () {
                          quest.claim();
                        },
                      )
                    )
                  ),
                  Flexible(flex: 4, child: Center(child: Text('${quest.count} / ${quest.total}'),))
                ],
              ) 
            )
          ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: quests.length,
      itemBuilder: (BuildContext context, int index) {
        return questWidget(quests[index]);
      }
    );

  }
}

class _QuizQuestList extends StatelessWidget {

  final List<QuizQuest> quests;

  const _QuizQuestList({Key? key, required this.quests}) : super(key: key);

  Widget questWidget(QuizQuest quest) {
    return SizedBox(
        height: 150,
        child: Row(
            children: [
              Flexible(flex: 8, child: Text('Do ${quest.game} with topic ${quest.chapter}')),
              Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      Visibility(
                          visible: quest.count >= quest.total,
                          child: Flexible(
                              flex: 6,
                              child: TextButton(
                                child: Center(child: quest.status == QUEST_STATUS.CLAIMED ? Text("Claimed") : Text("Claim")),
                                onPressed: () {
                                  quest.claim();
                                },
                              )
                          )
                      ),
                      Flexible(flex: 4, child: Center(child: Text('${quest.count} / ${quest.total}'),))
                    ],
                  )
              )
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: quests.length,
        itemBuilder: (BuildContext context, int index) {
          return questWidget(quests[index]);
        }
    );

  }
}
