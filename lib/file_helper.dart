import 'dart:convert';
import 'dart:io';

import 'package:eagle_eye/logger_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';

class FileHelper {
  static Future<EagleEyeConfig> getAndCheckIfConfigFileExists(
      String configFile) async {
    final file = File(configFile);
    if (!file.existsSync()) {
      LoggerHelper.printError('$configFile not found!');
      exit(1);
    }
    final textContent = await file.readAsString();

    List<dynamic> jsonData = jsonDecode(textContent);

    List<EagleEyeConfigItem> eagleConfigItems = [];
    for (var jsonItem in jsonData) {
      eagleConfigItems
          .add(EagleEyeConfigItem.fromJson(jsonItem as Map<String, dynamic>));
    }

    return EagleEyeConfig(items: eagleConfigItems);
  }

  static Directory getAndCheckIfLibsDirectoryExists(String libsFolderName) {
    final projectDirectory = Directory(libsFolderName);

    if (!projectDirectory.existsSync()) {
      LoggerHelper.printError('❌ Folder not found: $libsFolderName');
      exit(1);
    }
    return projectDirectory;
  }

  static List<File> allDartFiles(Directory directory) {
    final dartFiles = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    return dartFiles.toList();
  }
}
