import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/theme.dart';

class GoldWidget extends StatelessWidget {
  final int gold;

  const GoldWidget({Key? key, required this.gold}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

}