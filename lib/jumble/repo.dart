import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/jumble/destroyer.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/repository/kana.dart';
import 'package:kanji_memory_hint/repository/repo.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


const TOTAL_OPTIONS = 8;


Future<List<JumbleQuestionSet>> jumbleQuestionSets(int n, int chapter, GAME_MODE mode, bool quiz) async {
  var kanjis = await ByChapterForQuestion(chapter, n, 1/2, quiz);

  return _build(kanjis, mode);
}


Future<List<JumbleQuestionSet>> _build(List<KanjiExample> kanjis, GAME_MODE mode) async {

  if(mode == GAME_MODE.imageMeaning) {
    var optionCandidates = await random(startChapter: 1, endChapter: 8);

    return kanjis.map((kanji) {
      return _makeQuestionSet(kanji, optionCandidates, mode);
    }).toList();
  } else {
    List<JumbleQuestionSet> sets = [];

    for (var kanji in kanjis) {
      sets.add(await _makeReading(kanji));
    }

    return sets;
  }
}

Future<JumbleQuestionSet> _makeReading(KanjiExample kanji) async {
  String questionVal = "";

  List<String> correctKeys = [];
  correctKeys = kanji.spelling;
  questionVal = kanji.rune;

  final keysToTake = TOTAL_OPTIONS - correctKeys.length;
  // optionCandidates.shuffle();
  // var chosens = optionCandidates.take(keysToTake);
  
  // chosens.forEach((chosen) {
  //   optionVals += kanji.spelling;
  // });
  var hiraganas = await KanaRepository.hiragana(correctKeys);
  hiraganas.shuffle();
  var optionVals = hiraganas.take(keysToTake).map((hiragana) => hiragana.rune).toList();
  optionVals = correctKeys + optionVals.take(keysToTake).toList();
  optionVals.shuffle();

  JumbleQuestion question = JumbleQuestion(value: questionVal, key: correctKeys, isImage: false);
  List<Option> options = optionVals.mapIndexed((value, i) {
    return Option(id: i, value: value, key: value);
  }).toList();

  return JumbleQuestionSet(question: question, options: options);
}

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
    optionCandidates.shuffle();
    var chosens = optionCandidates.take(keysToTake);
    
    chosens.forEach((chosen) {
      optionVals += kanji.spelling;
    });
    // var otherOptions = await KanaRepository.hiragana(correctKeys);


    optionVals = correctKeys + optionVals.take(keysToTake).toList();

    optionVals.shuffle();
  }

  JumbleQuestion question = JumbleQuestion(value: questionVal, key: correctKeys, isImage: GAME_MODE.imageMeaning == mode);
  List<Option> options = optionVals.mapIndexed((value, i) {
    return Option(id: i, value: value, key: value);
  }).toList();

  return JumbleQuestionSet(question: question, options: options);
}



