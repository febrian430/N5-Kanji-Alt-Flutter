import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/repository/repo.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


Future<List<List<Question>>> makeOptions(int n, int chapter, GAME_MODE mode) async {

  List<List<Question>> options = [];

  var singles = await ByChapterWithSingle(chapter, true);
  var doubles = await ByChapterWithSingle(chapter, false);

  singles = singles.take(n).toList();
  doubles = doubles.take(n).toList();
  
  if(mode == GAME_MODE.imageMeaning) {
    options = await Future.wait([_makeImageMeaningOptions(singles), _makeImageMeaningOptions(doubles)]);
  } else {
    options =  await Future.wait([_makeReadingOptions(singles), _makeReadingOptions(doubles)]);
  }

  return options;
}

Future<List<Question>> _makeImageMeaningOptions(List<KanjiExample> candidates) async {
    List<Question> imageOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index, value: kanji.image, key: kanji.id.toString(), isImage: true);
    }).toList();

    var last = imageOptions.length;

    List<Question> runeOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index+last, value: kanji.rune, key: kanji.id.toString());
    }).toList();

    final List<Question> options = [...imageOptions, ...runeOptions];
    options.shuffle();

    return options;
}

Future<List<Question>> _makeReadingOptions(List<KanjiExample> candidates) async {
    List<Question> runeOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index, value: kanji.rune, key: kanji.id.toString());
    }).toList();

    var last = runeOptions.length;

    List<Question> spellingOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index+last, value: kanji.spelling.join(""), key: kanji.id.toString());
    }).toList();

    final List<Question> options = [...runeOptions, ...spellingOptions];
    options.shuffle();

    return options;
}