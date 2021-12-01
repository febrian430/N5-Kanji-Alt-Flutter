import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/repository/multiple_choice.repo.dart';

typedef OnOptionSelectCallback = Function(Option option);
typedef RoundOverCallback = Function(bool isCorrect); 



class MultipleChoiceGame extends StatefulWidget {
  MultipleChoiceGame({Key? key}) : super(key: key) {
    questionSets = _getQuestionSet();
  } 

  late final Future<List<QuestionSet>> questionSets;

  Future<List<QuestionSet>> _getQuestionSet() async {
    print("rebuilded qestion");
     return multipleChoiceQuestionSet(10);
  }

  @override
  State<StatefulWidget> createState() => _MultipleChoiceGameState();
}


class _MultipleChoiceGameState extends State<MultipleChoiceGame> {
  int score = 0;
  var _getQuestion;

  @override
  void initState() {
    super.initState();
    _getQuestion = widget._getQuestionSet();
  }

  void _handleOnSelect(bool isCorrect) {
      setState(() {
        if(isCorrect){
          score++;
        } else {
          score--;
        }
      });
      print("current score:" + score.toString());
  }

  Widget _buildRound(BuildContext context, int itemIndex, List<QuestionSet> data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: GameRound(
        question: data[itemIndex].question, 
        options: data[itemIndex].options, 
        mode: GAME_MODE.imageMeaning, 
        onSelect: (bool isCorrect) => _handleOnSelect(isCorrect),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const  Text('Multiple Choice'),
      ),
      // body: SafeArea(child:
      //         ListView(
      //           children: 
      //             widget.questionSets.map((QuestionSet questionSet) {
      //               return GameRound(question: questionSet.question, options: questionSet.options, mode: GAME_MODE.imageMeaning , onSelect: (bool isCorrect) => _handleOnSelect(isCorrect),);
      //             }).toList()
      //           ,
      //           scrollDirection: Axis.horizontal,
      //         ),
      //       )
      body: FutureBuilder(
        future: _getQuestion,
        builder: (context, AsyncSnapshot<List<QuestionSet>> snapshot) {
          if(snapshot.hasData) {
            return PageView.builder(
              // store this controller in a State to save the carousel scroll position
              controller: PageController(
                viewportFraction: 1,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int itemIndex) {
                return _buildRound(context, itemIndex, snapshot.data!);
              },
            );
          } else {
            return const Center(
              child: Text(
                'Loading',
              ),
            );
          }
        }
      )
      );
    // return const Text('hi');
  }
}

class GameRound extends StatefulWidget  {
  const GameRound({Key? key, required this.question, required this.options, required this.mode, required this.onSelect}) : super(key: key);

  final Question question;
  final List<Option> options;
  final GAME_MODE mode;
  final RoundOverCallback onSelect;

  @override
  State<StatefulWidget> createState() => _GameRoundState();
}

class _GameRoundState extends State<GameRound> with AutomaticKeepAliveClientMixin<GameRound> {
  Option? selected;
  bool gameOver = false;

  void _handleSelect(Option opt) {
    setState(() {
      selected = opt;
      gameOver = true;
    });
    widget.onSelect(opt.key == widget.question.key);
  }

  @override
  bool get wantKeepAlive => true;

  Widget _getQuestionWidget(Question question) {
    if(widget.mode == GAME_MODE.imageMeaning) {
      return Image(
        image: AssetImage(KANJI_IMAGE_FOLDER + question.value),
        height: 300,
        width: 300,
        fit: BoxFit.fill,
      );
    } else {
      return Text(question.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container( 
      child: Center(
        child: Column(
          children: [
            Center(
              child: Container(
                child: _getQuestionWidget(widget.question),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 3
                  )
                ),
              )
            ),
            Center(child: Text((widget.question.key.toString())),),
            Column(
                children: widget.options.map((Option opt) {
                  return GameOption(option: opt, isSelected: selected?.key == opt.key, disabled: gameOver, correctKey: widget.question.key.toString(), onSelect: (option) {
                    _handleSelect(opt);
                    print(selected?.value);
                  });
                }).toList(),
            )
          ],
        ),
      ),

      
    );
  }
}

class GameOption extends StatelessWidget {
  const GameOption({Key? key, required this.option, required this.isSelected, required this.disabled, required this.correctKey, required this.onSelect}): super(key: key);

  final Option option;
  final bool isSelected;
  final bool disabled;

  final String correctKey;
  final OnOptionSelectCallback onSelect;

  Color _getBackgroundColor(BuildContext buildContext) {
    
    
    if((disabled || isSelected) && correctKey == option.key) {
      return Colors.green;
    } else if(isSelected) {
      return Colors.red;
    } else if(disabled) {
      return Colors.grey;
    } 
    
    return Colors.white;
  }

  TextStyle? _getTextStyle(BuildContext buildContext) {
    if(isSelected || disabled) {
      return const TextStyle(
      color: Colors.white
    );;
    }
    return const TextStyle(
      color: Colors.black
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => disabled ? null : onSelect(option),
      child: Container(
        color: _getBackgroundColor(context),
        child: Center(
          child: Text(option.value + '\t' + option.key.toString(), style: _getTextStyle(context),),),
        width: 180,
        height: 60
      ),
      
    );
  }
}