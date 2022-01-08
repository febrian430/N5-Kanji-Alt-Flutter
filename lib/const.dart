// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';

const MIGRATE=false;

enum GAME_MODE { imageMeaning, reading }

extension GAME_MODE_MAP on GAME_MODE {
  String get name {
    switch (this) {
      case GAME_MODE.imageMeaning:
        return "IMG_MEANING";
      case GAME_MODE.reading:
        return "READING";
    }
  }

  static GAME_MODE? fromString(String value) {
    switch (value) {
      case "IMG_MEANING":
        return GAME_MODE.imageMeaning;
      case "READING":
        return GAME_MODE.reading;
    }
  }
}

enum QUEST_STATUS { ONGOING, COMPLETE, CLAIMED }

extension QUEST_STATUS_MAP on QUEST_STATUS {
  String get name {
    switch (this) {
      case QUEST_STATUS.ONGOING:
        return "ONGOING";
      case QUEST_STATUS.CLAIMED:
        return "CLAIMED";
      case QUEST_STATUS.COMPLETE:
        return "COMPLETE";
    }
  }

  static QUEST_STATUS? fromString(String value) {
    switch (value) {
      case "ONGOING":
        return QUEST_STATUS.ONGOING;
      case "CLAIMED":
        return QUEST_STATUS.CLAIMED;
      case "COMPLETE":
        return QUEST_STATUS.COMPLETE;
    }
  }
}

const GAME_MODE_IMG = "IMG_MEANING";


const KANJI_IMAGE_FOLDER = 'assets/images/kanji/';
const APP_IMAGE_FOLDER = 'assets/images/app/';

const MultipleChoiceRoute = '/game/multiple-choice';
const MixMatchRoute = '/game/mix-match';
const JumbleRoute = '/game/pick-drop';
const PickDropRoute = '/game/pick-drop';

const GameNumOfRounds = 5;
const CHAPTERS = 3;

const Widget EmptyWidget = Visibility(child: Text(""), visible: false,);