
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:permission_handler/permission_handler.dart';

const _folderName = 'kantan_kanji_library';
const _savePath = '/storage/emulated/0/Download/$_folderName/';

Future<void> _createFolderIfNotExists() async {
  final path = Directory('/storage/emulated/0/Download/$_folderName');

  if(!await path.exists()){
    await path.create();
  }
}


Future<bool> saveImage(String filename) async {
  var storagePermission = await Permission.storage.request();
  if(storagePermission.isGranted) {
    await _createFolderIfNotExists();

    File  file = File('$_savePath$filename');
    final byteData = await rootBundle.load(KANJI_IMAGE_FOLDER+filename);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return true;
  } else {
    return false;
  }
}