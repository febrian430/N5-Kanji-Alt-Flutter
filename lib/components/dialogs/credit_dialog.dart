import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/containers/double_border_container.dart';

class CreditsDialog extends StatelessWidget {

  Widget _titles(BuildContext context, String title, String content, { String? content2 }) {
    return _CreditsItem(
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          content2 != null ? 
          Text(
            content2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          )
          :
          SizedBox(),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      child: TwoBorderContainer(
        height: size.height*.7,
        width: size.width*.75,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child:  Column(
              children: [
                Text(
                  "Credits",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                ),
                _CreditsItem(
                  child: Text(
                    "Kantan Kanji: Credits",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )
                ),
                _titles(context, "Content Creator", "Matius"),
                _titles(context, "Art Design, UI/UX Design", "Alvin"),
                _titles(context, "Programmer", "Febrian"),
                _titles(context, "Resources", "Chieko Kano, Yuri Shimizu, Hiroko Yabe, Eriko Ishii - BASIC KANJI BOOK Vol.1, BOJINSHA CO., LTD (2015)"),
                _titles(context, "Music", "Sakuya 2 - 音楽素材Peritune ( https://peritune.com/ )",
                  content2: "Miyako Japan 2 - SHW ( http://en.shw.in/sozai/japan.php )"
                ),
              ],
            ),
          )
        )
      ),
    );
  }
}

class _CreditsItem extends StatelessWidget {
  final Widget child;

  const _CreditsItem({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height*.02,
      ),
      child: Center(child: child),
    );
  }

}