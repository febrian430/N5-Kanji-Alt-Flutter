import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/buttons/back_button.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String japanese;

  const AppHeader({Key? key, required this.title, required this.japanese}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: AppBackButton(context),
          ),
          Expanded(
            flex: 8,
            child: Column(
              children: [
                Center(child: Text(title)),
                Center(child: Text(japanese)),
              ],
            ), 
          ),
          Expanded(
            flex: 2,
            child: SizedBox()
          ) 
        ],
      )    
    );
  }

  
}