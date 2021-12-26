import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/back_button.dart';

class Menu extends StatelessWidget {

  final String title;
  final String titleJapanese;
  final Widget child;

  const Menu({Key? key, required this.title, required this.titleJapanese, required this.child}) : super(key: key);

  Widget titleWidget(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Container(
        child: Column(
          children: [
            Center(child: Text(title)),
            Center(child: Text(titleJapanese)),
          ],
        ),
      ),
    );
  }

  Widget backWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Flexible(
      flex: 2,
      child: Center(
        child: Container(
          height: size.height*0.09,
          width: size.height*0.16,
          child: AppBackButton(context)
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            titleWidget(context),
            Flexible(
              flex: 6,
              child: child
            ),
            backWidget(context)
          ],
        )
      )
    );
  }
}