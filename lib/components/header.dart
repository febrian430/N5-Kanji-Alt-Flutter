import 'package:flutter/cupertino.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String japanese;

  const AppHeader({Key? key, required this.title, required this.japanese}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: [
            Center(child: Text(title)),
            Center(child: Text(japanese)),
          ],
        ),
      );
  }

  
}