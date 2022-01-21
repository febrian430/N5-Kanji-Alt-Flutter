import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/audio_repository/audio.dart';
import 'package:kanji_memory_hint/components/buttons/icon_button.dart';
import 'package:kanji_memory_hint/icons.dart';

class AudioWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget>  {

  bool isMuted = AudioManager.isMuted;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      onTap: (){
        setState(() {
          isMuted = AudioManager.toggleMute();
        });
      }, 
      iconPath: isMuted ?  AppIcons.soundMute : AppIcons.sound, 
      height: 40, 
      width: 40,
      ratio: 1, 
      backgroundColor: Colors.transparent,
      noBorder: true,
    );
  }

}