// ignore_for_file: constant_identifier_names

enum GAME_MODE { imageMeaning, reading }

const KANJI_IMAGE_FOLDER = 'assets/images/kanji/';

const MultipleChoiceRoute = '/game/multiple-choice';
const MixMatchRoute = '/game/mix-match';
const JumbleRoute = '/game/pick-drop';
const PickDropRoute = '/game/pick-drop';

class PracticeGameArguments {
    PracticeGameArguments({required this.selectedGame});

    int chapter = 1;
    GAME_MODE mode = GAME_MODE.imageMeaning;
    String selectedGame; 
}