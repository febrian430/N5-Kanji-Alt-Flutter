import 'package:just_audio/just_audio.dart';

const String _menuMusic = "assets/audio/sakuya.mp3";
const String _gameMusic = "assets/audio/miyako.mp3";


class AudioBit {
  static final player = AudioPlayer();
  final String path;
  final int id;

  AudioBit(this.path, this.id);

  void play() async {
    await player.setAsset(path);
    await player.setLoopMode(LoopMode.one);
    
    player.play();
  }

  void stop() {
    player.stop();
  }
}

class AudioManager {
  static final _game = AudioBit(_gameMusic, 1);
  static final _menu = AudioBit(_menuMusic, 2);
  static AudioBit? _current;
  static bool _mute = false;

  static void _play(AudioBit audio) {
    print(_current == _menu);
    if(!_mute && (_current == null || _current?.id != audio.id)) {
      _current = audio;

      audio.play();
    }
  }

  static void playMenu() {
    _play(_menu);
  }

  static void playGame() {
    _play(_game);
  }

  static void toggleMute() {
    if(!_mute){
      _current?.stop();
      _mute = true;
    } else {
      _current?.play();
      _mute = false;
    }

  }
}