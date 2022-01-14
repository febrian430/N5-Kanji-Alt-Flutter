import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/buttons/icon_button.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/components/dialogs/reminder.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/game.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/images.dart';
import 'package:kanji_memory_hint/kanji-list/kanji_view.dart';
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
import 'package:kanji_memory_hint/reward/reward_screen.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/test.dart';
import 'package:kanji_memory_hint/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifier.initialize();
  await SQLRepo.open();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(new MyApp());
    });
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
        
        fontFamily: 'NotoSansJP',

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
            fontFamily: 'NotoSansJP',
            fontSize: 18
          )
        ),

        

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            side: const BorderSide(width: 2, color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero
            ),
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'NotoSansJP'
            )
          )
        )
      ),
      initialRoute: '/',
      routes: { 
        '/': (context) => const MainScreen(),
        '/list': (context) => KanjiList(),
        '/list/view': (context) => KanjiView(),
        '/game': (context) => GameSelect(),
        '/start-select': (context) => StartSelect(),
        '/chapter-select': (context) => ChapterSelect(),
        '/mode-select': (context) => const ModeSelect(),
        '/result': (context) => ResultScreen(),
        '/quests': (context) => QuestScreen(),
        '/rewards': (context) => RewardScreen(),
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
                return MixMatchGame(mode: args.mode, chapter: args.chapter, prevQuestions: args.mixMatchRestart,);
            });

          case JumbleGame.route:
            final args = settings.arguments as PracticeGameArguments;

            return MaterialPageRoute(builder: (context) {
                return JumbleGame(mode: args.mode, chapter: args.chapter, prevQuestions: args.jumbleRestart,);
            });
          
          case PickDrop.route:
            final args = settings.arguments as PracticeGameArguments;

            return MaterialPageRoute(builder: (context) {
                return PickDrop(mode: GAME_MODE.imageMeaning, chapter: args.chapter, prevQuestions: args.pickDropRestart,);
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

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  Widget _mainButtons(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 3,
          child: Column(
            children: [
              SelectButton(
                onTap: () {
                  Navigator.pushNamed(context, StartSelect.route);
                  
                },
                title: 'Start',
                iconPath: AppIcons.start,
                mainScreen: true,
              ),
              SelectButton(
                padding: EdgeInsets.symmetric(vertical: 10),
                onTap: () {
                  Navigator.pushNamed(context, '/list');
                },
                title: 'Kanji List',
                iconPath: AppIcons.list,
                mainScreen: true,

              ),
             SelectButton(
                onTap: () {
                  Navigator.pushNamed(context, '/quests');
                  
                },
                title: 'Quests',
                iconPath: AppIcons.quest,
                mainScreen: true,

              ),

            ],
          )
        ),
        Expanded(
          flex: 2,
          child: SizedBox(),
        ),
      ],
    );
  }

  Widget _bottomSettings(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(),
        ),
        Flexible(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppIconButton(
                onTap: (){
                  showDialog(
                    context: context, 
                    builder: (context) {
                      return ReminderDialog();
                    }
                  );
                }, 
                iconPath: AppIcons.reminder, 
                height: 40, 
                width: 40,
                ratio: 1, 
                backgroundColor: Colors.transparent,
                noBorder: true,
              ),
              AppIconButton(
                onTap: (){}, 
                iconPath: AppIcons.sound, 
                height: 40, 
                width: 40,
                ratio: 1, 
                backgroundColor: Colors.transparent,
                noBorder: true,
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MenuBackground(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width*0.1,
              vertical: size.height*0.1
            ),
            child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Image.asset(AppImages.logo),
              ),
              Expanded(
                flex: 6,
                child: _mainButtons(context),
              ),
              Expanded(
                flex: 1,
                child: _bottomSettings(context)
              )
            ]
          )
        )
        )
      ),
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
                iconPath: AppIcons.list,
              ),
            ),
            Center(
              child: SelectButton(
                onTap: () {
                  Navigator.pushNamed(context, StartSelect.route);
                  
                },
                title: 'Start',
                iconPath: AppIcons.start,
              ),
            ),
            Center(
              child: SelectButton(
                onTap: () {
                  Navigator.pushNamed(context, '/quests');
                  
                },
                title: 'Quests',
                iconPath: AppIcons.quest,
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
          ]
        )
      )
    );
  }
}