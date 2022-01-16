import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/containers/double_border_container.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/images.dart';
import 'package:kanji_memory_hint/theme.dart';

class KanaDialog extends StatelessWidget {
  const KanaDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    Widget _closeButton(BuildContext context) {
      return Row(
        children: [
          EmptyFlex(flex: 4),
          Expanded(
            flex: 3, 
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.wrong
              ),
              child: Text(
                "Close", 
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              onPressed: (){
                Navigator.pop(context);
              },
            )
          ),
          EmptyFlex(flex: 4)
        ],
      );
    }

    final size = MediaQuery.of(context).size;
    return Dialog(
      child: TwoBorderContainer(
        padding: EdgeInsets.all(6),
        child: Column(
          children: [
            Expanded(
              flex: 9, 
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Kana Chart",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 20,
                    child: Image.asset(
                      AppImages.kanaChart,
                      fit: BoxFit.contain,
                    ),
                  )
                ]
              )
            ),
            
            Expanded(flex: 1, child: _closeButton(context))
          ]
        ),
        height: size.height * 0.70,
        width: size.width * 0.90,
      ),
    );
  }

}