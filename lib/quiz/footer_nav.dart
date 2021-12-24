import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FooterNavigation extends StatelessWidget {
  
  FooterNavigationParam? prev;
  FooterNavigationParam? next;
  FooterNavigationParam? result;

  FooterNavigation({Key? key, this.result, this.prev, this.next}) : super(key: key);
  
  Widget _makeButton(FooterNavigationParam? param) {
    if(param == null) {
      return Container(
        color: Colors.transparent,
      );
    }

    return ElevatedButton(
      child: Center(
        child: Text(param.title),
      ),
      onPressed: param.onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(flex: 1, child: _makeButton(prev),),
        Flexible(flex: 1, child: _makeButton(result),),
        Flexible(flex: 1, child: _makeButton(next),),
      ],
    );
  }
}

class FooterNavigationParam {

  final String title;
  final Function() onTap;

  FooterNavigationParam({required this.title, required this.onTap});
}