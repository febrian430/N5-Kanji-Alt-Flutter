import 'package:just_audio/just_audio.dart';
import 'package:kanji_memory_hint/database/repository.dart';

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

class SoundFX {
  static final _player = AudioPlayer();
  static const String _correct = "assets/audio/correct2.wav";
  static const String _ado = "assets/audio/nice.wav";
  static const String _wrong = "assets/audio/wrong2.wav";

  static Future initialize() async {
    await _player.setAsset(_correct);
    await _player.setVolume(2.0);
    
  }

  static void correct() async {
    await _player.setAsset(_correct);
    await _player.setVolume(1.0);
    _player.seek(const Duration(seconds: 0));
    _player.play();
  }

  static void wrong() async {
    await _player.setAsset(_wrong);
    await _player.setVolume(1.0);
    _player.seek(const Duration(seconds: 0));
    _player.play();
  }
}

class AudioManager {
  static final _game = AudioBit(_gameMusic, 1);
  static final _menu = AudioBit(_menuMusic, 2);
  static AudioBit? _current;
  static bool _mute = false;

  static Future initialize() async {
    var flags = await SQLRepo.userFlags.get();
    _mute = flags.muted;
  }

  static bool get isMuted {
    return _mute;
  }

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

  static bool toggleMute() {
    if(!_mute){
      _current?.stop();
      _mute = true;
      SQLRepo.userFlags.setMute(true);
    } else {
      _current?.play();
      _mute = false;
      SQLRepo.userFlags.setMute(false);
    }
    return _mute;
  }
}