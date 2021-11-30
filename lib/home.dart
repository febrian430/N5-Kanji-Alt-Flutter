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
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              // Within the `Home` widget
              onPressed: () {
                // Navigate to the second screen using a named route.
                Navigator.pushNamed(context, '/list');
                
              },
              child: const Text('List'),
            ),
          ),
          Center(
            child: ElevatedButton(
              // Within the `Home` widget
              onPressed: () {
                // Navigate to the second screen using a named route.
                Navigator.pushNamed(context, '/game');
                
              },
              child: const Text('Start'),
            ),
          ),
      ]
    )
    );
  }
}