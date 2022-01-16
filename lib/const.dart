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

enum REWARD_STATUS { AVAILABLE, CLAIMED }

extension REWARD_STATUS_MAP on REWARD_STATUS {
  String get name {
    switch (this) {
      case REWARD_STATUS.AVAILABLE:
        return "AVAILABLE";
      case REWARD_STATUS.CLAIMED:
        return "CLAIMED";
    }
  }

  static REWARD_STATUS? fromString(String value) {
    switch (value) {
      case "AVAILABLE":
        return REWARD_STATUS.AVAILABLE;
      case "CLAIMED":
        return REWARD_STATUS.CLAIMED;
    }
  }
}

enum GAME_TYPE { PRACTICE, QUIZ }

const KANJI_IMAGE_FOLDER = 'assets/images/kanji/';
const APP_IMAGE_FOLDER = 'assets/images/app/';
const STROKE_ORDER_FOLDER = 'assets/images/stroke_order/';

const GameNumOfRounds = 3;
const CHAPTERS = 3;
const USE_CHAPTERS = [3,4,5];

const Widget EmptyWidget = Visibility(child: Text(""), visible: false,);