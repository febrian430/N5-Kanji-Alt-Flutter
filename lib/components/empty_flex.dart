import 'package:flutter/cupertino.dart';

class EmptyFlex extends StatelessWidget {
  final int flex;

  const EmptyFlex({Key? key, required this.flex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: SizedBox());
  }

}