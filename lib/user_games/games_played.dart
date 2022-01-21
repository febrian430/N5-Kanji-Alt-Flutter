import 'package:kanji_memory_hint/database/repository.dart';

const _hasPlayedMixMatch = "has_played_mixmatch";
const _hasPlayedJumble = "has_played_jumble";
const _hasPlayedPickDrop = "has_played_pickdrop";

class GamesPlayed {
  static bool mixmatch = false;
  static bool jumble = false;
  static bool pickdrop = false;

  static Future initialize() async {
    var flags = await SQLRepo.userFlags.get();

    mixmatch = flags.mixmatch;
    jumble = flags.jumble;
    pickdrop = flags.pickdrop;
  }

  static Future setMixMatchTrue() async {
    SQLRepo.userFlags.setMixMatchTrue();
    mixmatch = true;
  }

  static Future setJumbleTrue() async {
    SQLRepo.userFlags.setJumbleTrue();
    jumble = true;
  }
  static Future setPickDropTrue() async {
    SQLRepo.userFlags.setPickdropTrue();
    pickdrop = true;
  }
}
