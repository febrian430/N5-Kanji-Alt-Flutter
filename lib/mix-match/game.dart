import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/mix-match/repo.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/route_param.dart';

typedef OnRoundOverCallback = Function(bool isCorrect, int correct, int wrongAttempts);

class MixMatchGame extends StatefulWidget {
  MixMatchGame({Key? key, required this.chapter, required this.mode}) : super(key: key);

  final int chapter;
  final GAME_MODE mode;
  final int numOfRounds = 2;

  static const route = '/game/mix-match';
  static const name = 'Mix and Match';

  Future<List<List<Question>>> _getQuestionSet(int chapter, GAME_MODE mode) async {
    return makeOptions(6, chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _MixMatchGameState();
}

class _MixMatchGameState extends State<MixMatchGame> {
  var _questionSet;

  int roundsSolved = 0;
  int wrong = 0;

  @override
  void initState() {
    super.initState();
    // PracticeGameArguments arg = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;
    _questionSet = widget._getQuestionSet(widget.chapter, widget.mode);
  }

  void _onRoundOver(bool isCorrect, int correct, int wrongAttempts) {
    setState(() {
      wrong += wrongAttempts;
      roundsSolved++;
    });
    print("was called");
  }

  Widget _buildRound(BuildContext context, int index, List<List<Question>> data) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Container(
            height: size.height*0.85,
            child: _MixMatchRound( 
              options: data[index], 
              onRoundOver: _onRoundOver,
            )
          ),
          ResultButton(
            param: ResultParam(wrongCount: wrong, decreaseFactor: 100),
            visible: widget.numOfRounds == roundsSolved,
          ),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _questionSet,
        builder: (context, AsyncSnapshot<List<List<Question>>> snapshot) {
          if(snapshot.hasData) {
            return PageView.builder(
              controller: PageController(
                viewportFraction: 1,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int itemIndex) {
                return _buildRound(context, itemIndex, snapshot.data!);
              }
            );
          } else {
            return LoadingScreen();
          }
        }
      )
    );    
  }
}

class _MixMatchRound extends StatefulWidget {
  
  _MixMatchRound({Key? key, required this.options, required this.onRoundOver}): super(key: key);

  final List<Question> options;
  final OnRoundOverCallback onRoundOver;

  @override
  State<StatefulWidget> createState() => _MixMatchRoundState();
}

class _MixMatchRoundState extends State<_MixMatchRound> with AutomaticKeepAliveClientMixin {
  int score = 0;
  int wrong = 0;
  late int numOfQuestions; 

  Question? selected;
  List<Question> solved = [];


  @override
  bool get wantKeepAlive => true;


  Widget _drawQuestionWidget(Question opt) {
    bool isSelected = (selected?.id == opt.id);
    bool isSolved = solved.contains(opt);

    if(opt.isImage){
      double opacity = isSelected || isSolved ? 0.5 : 1;
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(KANJI_IMAGE_FOLDER + opt.value),
            fit: BoxFit.fill,
            
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(opacity), BlendMode.dstATop)
          ),
          border: isSelected ? Border.all(
            color:  Colors.green,
            width: 2
          ) : null,
        ),
        height: 120,
        width: 120,
      );
    } else {
    
      BoxDecoration? deco;

      if(isSelected) {
        deco = BoxDecoration(
            border: Border.all(
              color: Colors.green,
              width: 2
            )
          );
      } else if(isSolved) {
        deco = BoxDecoration(
            border: Border.all(
              color: Colors.red,
              width: 2
            )
          );
      } else {
        deco = BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1
            )
          );
      }

      return Container( 
        child: Center(
          child: Text(opt.value + " " + opt.key),
        ),
        decoration: deco,
        height: 120,
        width: 120,
      );
    }
  }

  void _deselect(Question opt) {
    setState(() {
      selected = null;
    });

    print("deselect " + opt.value.toString());

  }

  void _select(Question opt) {
    setState(() {
      selected = opt;
    });
    print("select " + opt.value.toString());
  }

  void _isGameOver() async {
    if(solved.length == numOfQuestions){
      widget.onRoundOver(true, score, wrong);
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Game over'),
          content: Text('Wrong attempts: ' + wrong.toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _evaluate(Question opt) {
    if(selected?.key == opt.key) {
      setState(() {
        solved = [...solved, opt, selected!];
        selected = null;
      });
      _isGameOver();
      print("correct");
    } else {
      setState(() {
        selected = null;
        wrong++;
      });
      print("incorrect");
    }
  }

  void _handleTap(Question opt) {
    if(!solved.contains(opt)) {
      if(selected == null) {
        _select(opt);
      } else if(selected?.value == opt.value) {
        _deselect(opt);
      } else {
        _evaluate(opt);
      }
    }
  }

  Widget _buildQuestion(Question opt) {
    return GestureDetector(
            child: Container(
              child: _drawQuestionWidget(opt)
            ),
            onTap:() {
              setState(() {
                _handleTap(opt);
             });
            },
          );
  }

  Widget _getGameUI(BuildContext context, List<Question> questions) {
    numOfQuestions = questions.length;
    return Center(
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: NeverScrollableScrollPhysics(),
                children: questions.map((opt) {
                  return _buildQuestion(opt);
                }).toList(),
              )
            )
          ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // PracticeGameArguments arg = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;
    
    return _getGameUI(context, widget.options);
  }


}