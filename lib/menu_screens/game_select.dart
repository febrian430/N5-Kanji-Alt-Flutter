import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold( 
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Center(
                child: ElevatedButton(
                  // Within the `Home` widget
                  onPressed: () {
                    // Navigate to the second screen using a named route.
                    Navigator.pushNamed(context, '/game/jumble');
                    
                  },
                  child: const Text('Jumble'),
                ),
              ),
            ]
          )
      )
    );
  }
}