import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/jumble/destroyer.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/repository/repo.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


const TOTAL_OPTIONS = 8;


Future<List<JumbleQuestionSet>> jumbleQuestionSets(int n, int chapter, GAME_MODE mode) async {
  var kanjis = await ByChapterRandom(chapter);
  var candidates = kanjis.take(n);

  var optionCandidates = await random(startChapter: 1, endChapter: 8);

  return candidates.map((candidate) {
    return _makeQuestionSet(candidate, optionCandidates, mode);
  }).toList();

}

// Future<List<JumbleQuestionSet>> _getReadingQuestions(int n, int chapter) async {
  
// }

// Future<List<JumbleQuestionSet>> _getImageMeaningQuestions(int n, int chapter) async {

// }

//todo: REFACTOR
JumbleQuestionSet _makeQuestionSet(KanjiExample kanji, List<KanjiExample> optionCandidates, GAME_MODE mode) {

  String questionVal = "";
  List<String> optionVals = [];

  List<String> correctKeys = [];
  DestroyerFunc destroy = getDestroyer(mode);

  if(GAME_MODE.imageMeaning == mode) {
    correctKeys = kanji.rune.split("");
    questionVal = kanji.image;

    final keysToTake = TOTAL_OPTIONS - correctKeys.length;
    print(keysToTake);
    optionCandidates.shuffle();
    var chosens = optionCandidates.take(keysToTake);
    
    chosens.forEach((chosen) {
      optionVals += chosen.rune.split("");
    });

    optionVals = correctKeys + optionVals.take(keysToTake).toList();

    optionVals.shuffle();
  } else {
    correctKeys = kanji.spelling;
    questionVal = kanji.rune;

    final keysToTake = TOTAL_OPTIONS - correctKeys.length;
    print(keysToTake);
    optionCandidates.shuffle();
    var chosens = optionCandidates.take(keysToTake);
    
    chosens.forEach((chosen) {
      optionVals += kanji.spelling;
    });
    optionVals = correctKeys + optionVals.take(keysToTake).toList();

    optionVals.shuffle();
  }

  JumbleQuestion question = JumbleQuestion(value: questionVal, key: correctKeys, isImage: GAME_MODE.imageMeaning == mode);
  List<Option> options = optionVals.mapIndexed((value, i) {
    return Option(id: i, value: value, key: value);
  }).toList();

  return JumbleQuestionSet(question: question, options: options);
}



