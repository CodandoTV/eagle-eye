import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:eagle_eye/analyzer/eagle_eye_matcher.dart';
import 'package:eagle_eye/analyzer/eagle_eye_visitor.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/data/eagle_eye_repository.dart';
import 'package:eagle_eye/data/file_helper.dart';
import 'package:eagle_eye/data/json_converter.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/error_info.dart';
import 'package:eagle_eye/util/logger_helper.dart';

/// The main launcher for Eagle Eye architecture validation.
///
/// [EagleEyeLauncher] coordinates the analysis of a Dart project using
/// the Eagle Eye tool. It performs the following steps:
/// 1. Loads the configuration file (`eagle_eye_config.json`) via
/// [EagleEyeRepository].
/// 2. Collects all Dart files in the `lib/` folder.
/// 3. Determines the application name from `pubspec.yaml`.
/// 4. Uses [EagleEyeMatcher] to find which rules apply to each file.
/// 5. Uses [EagleEyeVisitor] to analyze imports and collect violations.
/// 6. Logs errors using [LoggerHelper] and exits with a non-zero code if
/// violations exist.
class EagleEyeLauncher {
  late EagleEyeRepository _repository;

  /// Initializes the launcher with the default repository, file helper, and
  /// JSON converter.
  EagleEyeLauncher() {
    final fileHelper = FileHelper();
    _repository = EagleEyeRepositoryImpl(
      fileHelper: fileHelper,
      jsonConverter: JsonConverter(),
    );
  }

  /// Launches the Eagle Eye analysis on the current Dart project.
  ///
  /// This method:
  /// - Loads the configuration file and Dart source files.
  /// - Validates internal imports according to the rules defined in the
  /// configuration.
  /// - Collects all errors and prints them to the console.
  /// - Exits the process with a non-zero code if violations are found or
  /// critical files are missing.
  Future<void> launchEagleEye() async {
    EagleEyeConfig? configFile =
        await _repository.getAndCheckIfConfigFileExists();
    List<File>? dartFiles = _repository.allDartFiles();

    if (configFile == null) {
      LoggerHelper.printError(
        '❌ Unable to load configuration file. '
        'Please ensure that an eagle_eye_config.json file exists at the '
        'root of your project.',
      );
      exit(1);
    }

    if (dartFiles == null) {
      LoggerHelper.printError(
        '❌ Unable to load the dart files of your project.',
      );
      exit(1);
    }

    String? applicationName = _repository.getApplicationName();
    if (applicationName == null) {
      LoggerHelper.printError(
        '❌ Unable to find pubspec.yaml.',
      );
      exit(1);
    }

    final EagleEyeMatcher matcher = EagleEyeMatcher(
      config: configFile,
      regexHelper: RegexHelper(),
    );
    List<ErrorInfo> errors = [];

    for (final file in dartFiles) {
      final result = parseFile(
        path: file.path,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      EagleEyeConfigItem? eagleEyeItem = matcher.find(file.path);
      if (eagleEyeItem != null) {
        EagleEyeVisitor visitor = EagleEyeVisitor(
          configItem: eagleEyeItem,
          filePath: file.path,
          applicationName: applicationName,
          errorCallback: (error) => errors.add(error),
          regexHelper: RegexHelper(),
        );
        result.unit.visitChildren(visitor);
      }
    }

    for (var errorInfoItem in errors) {
      LoggerHelper.printError(
        '${errorInfoItem.errorMessage} - ${errorInfoItem.filePath}',
      );
    }

    if (errors.isNotEmpty) {
      LoggerHelper.printError(
          'Verification failed with ${errors.length} errors');
      exit(1);
    }
  }
}
