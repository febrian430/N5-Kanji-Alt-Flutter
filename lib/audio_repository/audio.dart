import 'package:just_audio/just_audio.dart';

const String _selectButton = "assets/audio/horse_whinney_2.mp3";

class AudioBit {
  static final player = AudioPlayer();
  final String path;

  AudioBit(this.path);

  void play() async {
    await player.setAsset(path);
    player.play();
  }
}

final SelectAudio = AudioBit(_selectButton);