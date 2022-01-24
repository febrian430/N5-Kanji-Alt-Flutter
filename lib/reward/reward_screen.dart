import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/database/user_point.dart';
import 'package:kanji_memory_hint/quests/screen/gold.dart';
import 'package:kanji_memory_hint/reward/reward_screen_layout.dart';
import 'package:kanji_memory_hint/reward/topic_reward.dart';
import 'package:kanji_memory_hint/theme.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


class RewardScreen extends StatefulWidget {
  
  static const route = '/rewards';
  static const name = 'Reward';
  final chapters = USE_CHAPTERS;

  RewardScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late Future<List<Example>> futureExamples;
  late Future<UserPoint> point;
  int gold = 0;
  bool goldLoaded = false;
  bool exampleLoaded = false;
  late List<Example> examples;
  int currentPage = 0;

  PageController _controller = PageController(
    viewportFraction: 1,
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();

    futureExamples = SQLRepo.examples.all();
    point = SQLRepo.userPoints.get();
  }

  Widget _pageView(BuildContext context){
    final size = MediaQuery.of(context).size;

    List<List<Example>> groupedPerChapter = widget.chapters.map((chapter){
      var examplesOfChapter = examples.where((example) => example.chapters.contains(chapter) && example.hasImage);
      return examplesOfChapter.toList();
    }).toList();

    return PageView(
      controller: _controller,
      onPageChanged: (int page) {
        currentPage = page;
      },
      children: groupedPerChapter.mapIndexed((examples, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width*0.062),
          child: TopicRewards(
            chapter: index+1,
            examples: examples, 
            gold: gold,
            onBuy: (int cost, int exampleId) {
              setState(() {
                gold -= cost;
                // examples = examples.where((example) => example.id == exampleId).
              });
            },
            onNext: index != groupedPerChapter.length-1 ? (){
                int current = _controller.page!.floor();
                currentPage = current+1;
                _controller.animateToPage(currentPage, 
                  duration: const Duration(milliseconds: 300), 
                  curve: Curves.linear
                );
            } : null,


            onPrev: index != 0 ? 
              (){
                  int current = _controller.page!.floor();
                  currentPage = current-1;
                  _controller.animateToPage(currentPage, 
                    duration: const Duration(milliseconds: 300), 
                    curve: Curves.linear
                  );
                
              } : null
          )
        );
      }).toList(),
    );
  }

  Widget screen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        ),
        color: AppColors.primary
      ),
      child: FutureBuilder(
        future: futureExamples,
        builder: (context, AsyncSnapshot<List<Example>> snapshot) {

          if(snapshot.hasData){
            if(!exampleLoaded) {
              examples = snapshot.data!;
              exampleLoaded = true;
            }
            
            return _pageView(context);
          } else {
            return LoadingScreen();
          }
        }
      )
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
        future: point,
        builder: (context, AsyncSnapshot<UserPoint> snapshot) {
          if(snapshot.hasData && !goldLoaded) {
            gold = snapshot.data!.gold;
            goldLoaded = true;
          }
          return RewardScreenLayout(
            child: screen(context),
            gold: GoldWidget(gold: gold, textAlign: TextAlign.right,)
          );
        }
    ); 
  }
}