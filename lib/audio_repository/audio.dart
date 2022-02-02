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
  final _player = AudioPlayer();
  final String _correct = "assets/audio/correct2.wav";
  final String _wrong = "assets/audio/wrong2.wav";
  final String _result = "assets/audio/result.mp3";

  late bool _isMuted;

  SoundFX(bool mute) {
    _isMuted = mute;
  }

  Future initialize() async {
    await _player.setVolume(1.0); 
  }

  void setMute(bool mute) {
    _isMuted = mute;
  }

  void _play(String audioPath) async {
    if(!_isMuted){
      await _player.setAsset(audioPath);
      _player.seek(const Duration(seconds: 0));
      _player.play();
    }
  }

  void correct() async {
    _play(_correct);
  }

  void wrong() async {
    _play(_wrong);
  }

  void result() async {
    _play(_result);
  }
}

class Music {
  final _game = AudioBit(_gameMusic, 1);
  final _menu = AudioBit(_menuMusic, 2);
  AudioBit? _current;
  late bool _isMuted;

  Music(bool mute) {
    _isMuted = mute;
  }

  void setMute(bool mute) {
    _isMuted = mute;
  }

  void _play(AudioBit audio) {
    if(!_isMuted && (_current == null || _current?.id != audio.id)) {
      _current = audio;
      audio.play();
    }
  }

  void menu() {
    _play(_menu);
  }

  void game() {
    _play(_game);
  }

  void current() {
    _current?.play();
  }

  void stop() {
    _current?.stop();
  }

}

class AudioManager {
  static late final Music music;
  static late final SoundFX soundFx;

  static bool _mute = false;

  static bool get isMuted {
    return _mute;
  }

  static Future initialize() async {
    var flags = await SQLRepo.userFlags.get();
    _mute = flags.muted;

    music = Music(_mute);
    soundFx = SoundFX(_mute);
  }

  

  static bool toggleMute() {
    if(!_mute){
      music.stop();
      _mute = true;
    } else {
      music.current();
      _mute = false;
    }

    SQLRepo.userFlags.setMute(_mute);
    music.setMute(_mute);
    soundFx.setMute(_mute);

    return _mute;
  }
}