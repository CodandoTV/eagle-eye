import 'dart:io';
import 'package:eagle_eye/model/exceptions/application_name_not_found_exception.dart';
import 'package:eagle_eye/model/exceptions/config_file_not_found_exception.dart';
import 'package:eagle_eye/model/exceptions/empty_dart_file_list_exception.dart';
import 'package:eagle_eye/model/exceptions/invalid_file_selection_exception.dart';
import 'package:eagle_eye/model/exceptions/library_folder_not_found_exception.dart';
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
  /// Throws a [ConfigFileNotFoundException] if the file does not exist.
  ///
  /// Returns the file content as a [String].
  Future<String> getAndCheckIfConfigFileExists(String configFile) async {
    final file = File(configFile);
    if (!file.existsSync()) {
      throw ConfigFileNotFoundException();
    }
    final textContent = await file.readAsString();
    return textContent;
  }

  /// Ensures the specified [libsFolderName] directory exists and returns it.
  ///
  /// Throws a [LibraryFolderNotFoundException] if the directory does not
  /// exist.
  ///
  /// Returns the [Directory] representing the `lib/` folder.
  Directory getAndCheckIfLibsDirectoryExists(String libsFolderName) {
    final projectDirectory = Directory(libsFolderName);

    if (!projectDirectory.existsSync()) {
      throw LibraryFolderNotFoundException();
    }
    return projectDirectory;
  }

  /// Returns a list of all `.dart` files found recursively in the given
  /// [directory].
  ///
  /// Return only includes files that end with the `.dart` extension
  /// Throw an [EmptyDartFileListException] if there is no dart file available.
  List<File> allDartFiles(Directory directory) {
    final dartFiles = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    if (dartFiles.isEmpty) {
      throw EmptyDartFileListException();
    } else {
      return dartFiles.toList();
    }
  }

  /// Selects the Dart [requestedFiles] that belong to [availableFiles].
  ///
  /// [availableFiles] contains every Dart file discovered under `lib/`.
  /// Paths may be absolute or relative and are normalized before comparison.
  /// Duplicates are removed while preserving the order in which they were
  /// first requested.
  ///
  /// Throws an [InvalidFileSelectionException] when a requested path does not
  /// exist, is not a `.dart` file, or is outside `lib/`.
  List<String> selectDartFiles({
    required List<String> availableFiles,
    required List<String> requestedFiles,
  }) {
    if (requestedFiles.isEmpty) {
      return availableFiles;
    }

    final byNormalizedPath = <String, String>{};
    for (final filePath in availableFiles) {
      byNormalizedPath[_normalizePath(filePath)] = filePath;
    }

    final problems = <String>[];
    final selected = <String>[];
    final seen = <String>{};

    for (final requestedPath in requestedFiles) {
      final normalizedPath = _normalizePath(requestedPath);
      if (!seen.add(normalizedPath)) {
        continue;
      }

      if (!requestedPath.endsWith('.dart')) {
        problems.add('$requestedPath is not a Dart (.dart) file.');
        continue;
      }

      if (!File(requestedPath).existsSync()) {
        problems.add('$requestedPath does not exist.');
        continue;
      }

      final availablePath = byNormalizedPath[normalizedPath];
      if (availablePath == null) {
        problems.add('$requestedPath is outside lib/.');
        continue;
      }

      selected.add(availablePath);
    }

    if (problems.isNotEmpty) {
      throw InvalidFileSelectionException(problems);
    }

    return selected;
  }

  String _normalizePath(String path) {
    return File(path).absolute.uri.normalizePath().toFilePath();
  }

  /// Reads the `pubspec.yaml` file and returns the application’s name.
  ///
  /// Returns `null` if the `pubspec.yaml` file is missing or cannot be parsed.
  /// Throw an [ApplicationNameNotFoundException] if no application name was
  /// provided in the pubspec.yaml
  String getApplicationName() {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      throw ApplicationNameNotFoundException();
    }

    final content = pubspecFile.readAsStringSync();
    final yaml = loadYaml(content);

    return yaml['name'];
  }
}
