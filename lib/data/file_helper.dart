import 'dart:io';
import 'package:eagle_eye/util/logger_helper.dart';
import 'package:yaml/yaml.dart';

/// Provides utility methods for interacting with project files and directories.
///
/// The [FileHelper] class is responsible for file system operations used by
/// the Eagle Eye tool, such as:
/// - Checking if the configuration file exists and reading its content.
/// - Verifying and retrieving the `lib/` directory.
/// - Listing all `.dart` source files in the project.
/// - Extracting the application name from the `pubspec.yaml` file.
class FileHelper {
  // Checks if the specified configuration file exists and reads its contents.
  ///
  /// If the file does not exist, logs an error message via [LoggerHelper].
  ///
  /// Returns the file content as a [String].
  Future<String> getAndCheckIfConfigFileExists(String configFile) async {
    final file = File(configFile);
    if (!file.existsSync()) {
      LoggerHelper.printError('$configFile not found!');
    }
    final textContent = await file.readAsString();
    return textContent;
  }

  /// Ensures the specified [libsFolderName] directory exists and returns it.
  ///
  /// If the directory does not exist, logs an error message via [LoggerHelper].
  ///
  /// Returns the [Directory] representing the `lib/` folder.
  Directory getAndCheckIfLibsDirectoryExists(String libsFolderName) {
    final projectDirectory = Directory(libsFolderName);

    if (!projectDirectory.existsSync()) {
      LoggerHelper.printError('Folder not found: $libsFolderName');
    }
    return projectDirectory;
  }

  /// Returns a list of all `.dart` files found recursively in the given
  /// [directory].
  ///
  /// Only includes files that end with the `.dart` extensi
  List<File> allDartFiles(Directory directory) {
    final dartFiles = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    return dartFiles.toList();
  }

  /// Reads the `pubspec.yaml` file and returns the application’s name.
  ///
  /// Returns `null` if the `pubspec.yaml` file is missing or cannot be parsed.
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
