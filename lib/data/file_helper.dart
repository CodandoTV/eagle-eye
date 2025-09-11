import 'dart:io';
import 'package:eagle_eye/util/logger_helper.dart';
import 'package:yaml/yaml.dart';

class FileHelper {
  Future<String> getAndCheckIfConfigFileExists(String configFile) async {
    final file = File(configFile);
    if (!file.existsSync()) {
      LoggerHelper.printError('$configFile not found!');
    }
    final textContent = await file.readAsString();
    return textContent;
  }

  Directory getAndCheckIfLibsDirectoryExists(String libsFolderName) {
    final projectDirectory = Directory(libsFolderName);

    if (!projectDirectory.existsSync()) {
      LoggerHelper.printError('Folder not found: $libsFolderName');
    }
    return projectDirectory;
  }

  List<File> allDartFiles(Directory directory) {
    final dartFiles = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    return dartFiles.toList();
  }

  String? getApplicationName() {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      return null;
    }

    final content = pubspecFile.readAsStringSync();
    final yaml = loadYaml(content);

    return yaml['name'];
  }
}
