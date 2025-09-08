import 'dart:io';
import 'package:eagle_eye/util/logger_helper.dart';

class FileHelper {
  final LoggerHelper loggerHelper;

  FileHelper({required this.loggerHelper});

  Future<String> getAndCheckIfConfigFileExists(String configFile) async {
    final file = File(configFile);
    if (!file.existsSync()) {
      loggerHelper.printError('$configFile not found!');
      exit(1);
    }
    final textContent = await file.readAsString();
    return textContent;
  }

  Directory getAndCheckIfLibsDirectoryExists(String libsFolderName) {
    final projectDirectory = Directory(libsFolderName);

    if (!projectDirectory.existsSync()) {
      loggerHelper.printError('❌ Folder not found: $libsFolderName');
      exit(1);
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
}
