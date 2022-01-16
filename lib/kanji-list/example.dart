import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/kanji.dart';

class ExampleContainer extends StatelessWidget {
  final Example example;
  final Kanji kanji;
  const ExampleContainer({Key? key, required this.example, required this.kanji}) : super(key: key);

  Widget _withNoImage(BuildContext context) {
    return Column(
        children: [
          Flexible(
            flex: 2, 
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 1))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(example.rune, style: TextStyle(fontWeight: FontWeight.bold),),
                      Text('( ${example.spelling.join('')} )'),
                    ],
                  )
                );
              }
            )
          ),
          Expanded(
            flex: 4,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 1))
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    kanji.rune,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MsMincho'
                    ),
                  ),
                );
              }
            )
          ),
          Expanded(
            flex: 1,
            child: Text(example.meaning, textAlign: TextAlign.center,),
          )
        ],
      );
  }

  Widget _withImage(BuildContext context) {
    return Column(
        children: [
          Flexible(
            flex: 2, 
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 1))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(example.rune, style: TextStyle(fontWeight: FontWeight.bold),),
                      Text('( ${example.spelling.join('')} )'),
                    ],
                  )
                );
              }
            )
          ),
          Expanded(
            flex: 4,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                child: Image.asset(
                  KANJI_IMAGE_FOLDER+example.image,
                  fit: BoxFit.contain,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1))
                ),
              ),
            )
          ),
          Expanded(
            flex: 1,
            child: Center(child: Text(example.meaning, textAlign: TextAlign.center,)),
          )
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
      child: example.hasImage ? _withImage(context) : _withNoImage(context)
    );
  }
}