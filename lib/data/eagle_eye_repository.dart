import 'dart:io';

import 'package:eagle_eye/data/file_helper.dart';
import 'package:eagle_eye/data/json_converter.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';

/// Defines the contract for accessing and loading Eagle Eye configuration
/// and project-related information.
///
/// The [EagleEyeRepository] provides methods to:
/// - Retrieve and parse the Eagle Eye configuration file.
/// - Locate all Dart files under the `lib/` directory.
/// - Determine the application’s name.
///
/// Implementations are responsible for handling file system operations
/// and converting raw data into [EagleEyeConfig] objects.
abstract class EagleEyeRepository {
  /// Retrieves and parses the Eagle Eye configuration file
  /// if it exists in the project root.
  ///
  /// Returns an [EagleEyeConfig] if the file exists and is valid,
  /// or `null` otherwise.
  Future<EagleEyeConfig?> getAndCheckIfConfigFileExists();

  /// Returns all Dart files found within the project’s `lib/` directory.
  ///
  /// Returns `null` if the directory doesn’t exist or cannot be read.
  List<File>? allDartFiles();

  /// Returns the application’s name as defined in the project structure.
  ///
  /// Returns `null` if the name cannot be determined.
  String? getApplicationName();
}

// Concrete implementation of [EagleEyeRepository] that uses
/// [FileHelper] and [JsonConverter] to interact with the file system
/// and configuration data.
///
/// This class is responsible for:
/// - Locating and parsing the `eagle_eye_config.json` file.
/// - Fetching all Dart source files from the `lib/` folder.
/// - Extracting the application name for dependency checks.
class EagleEyeRepositoryImpl extends EagleEyeRepository {
  /// The expected name of the Eagle Eye configuration file.
  static const configFileName = 'eagle_eye_config.json';

  /// The default folder containing Dart source code.
  static const libsFolderName = 'lib';

  /// Helper for interacting with the file system.
  FileHelper fileHelper;

  /// Helper for converting JSON data into Dart objects.
  JsonConverter jsonConverter;

  /// Creates a new [EagleEyeRepositoryImpl] instance.
  EagleEyeRepositoryImpl({
    required this.fileHelper,
    required this.jsonConverter,
  });

  @override
  List<File>? allDartFiles() {
    try {
      Directory libsDir = fileHelper.getAndCheckIfLibsDirectoryExists(
        libsFolderName,
      );
      return fileHelper.allDartFiles(libsDir);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<EagleEyeConfig?> getAndCheckIfConfigFileExists() async {
    try {
      final String configFileContent =
          await fileHelper.getAndCheckIfConfigFileExists(configFileName);

      return jsonConverter.convert(configFileContent);
    } catch (e) {
      return null;
    }
  }

  @override
  String? getApplicationName() {
    try {
      return fileHelper.getApplicationName();
    } catch (e) {
      return null;
    }
  }
}
