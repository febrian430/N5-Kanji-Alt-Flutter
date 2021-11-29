import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Screen'),
      ),
      body: Column(children: [
        Center(
          child: ElevatedButton(
            // Within the `Home` widget
            onPressed: () {
              // Navigate to the second screen using a named route.
              Navigator.pushNamed(context, '/game/multiple-choice');
              
            },
            child: const Text('Multiple Choice'),
          ),
        ),
        Center(
          child: ElevatedButton(
            // Within the `Home` widget
            onPressed: () {
              // Navigate to the second screen using a named route.
              Navigator.pushNamed(context, '/game/pick-drop');
              
            },
            child: const Text('Pick and Drop'),
          ),
        ),
        Center(
          child: ElevatedButton(
            // Within the `Home` widget
            onPressed: () {
              // Navigate to the second screen using a named route.
              Navigator.pushNamed(context, '/game/mix-match');
              
            },
            child: const Text('Mix and Match'),
          ),
        ),
      ]
    )
    );
  }
}