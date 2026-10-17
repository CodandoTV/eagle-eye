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
import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';
import 'package:eagle_eye/model/violation.dart';
import 'package:eagle_eye/util/check_reporter.dart';
import 'package:eagle_eye/util/cli_options.dart';
import 'package:eagle_eye/util/logger_helper.dart';
import 'package:eagle_eye/util/output_renderer.dart';

/// The main launcher for Eagle Eye architecture validation.
///
/// [EagleEyeLauncher] coordinates the analysis of a Dart project using
/// the Eagle Eye tool. It performs the following steps:
/// 1. Parses the command-line arguments.
/// 2. Loads the configuration file (`eagle_eye_config.json`) via
/// [EagleEyeRepository].
/// 3. Collects all Dart files in the `lib/` folder.
/// 4. Determines the application name from `pubspec.yaml`.
/// 5. Uses [EagleEyeMatcher] to find which rules apply to each file.
/// 6. Uses [EagleEyeVisitor] to analyze imports and collect violations.
/// 7. Logs errors using [LoggerHelper] and exits with a non-zero code if
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
  /// Accepts the raw command-line [args]. Pass `--verbose` (or `-v`) to print
  /// every configuration, file, import, and pattern check performed.
  ///
  /// This method:
  /// - Loads the configuration file and Dart source files.
  /// - Validates internal imports according to the rules defined in the
  /// configuration.
  /// - Collects all errors and prints them to the console.
  /// - Exits the process with a non-zero code if violations are found or
  /// critical files are missing.
  Future<void> launchEagleEye({List<String> args = const []}) async {
    late final CliOptions options;
    try {
      options = CliOptions.parse(args);
    } on FormatException catch (e) {
      LoggerHelper.printError(e.message);
      exit(1);
    }

    if (options.showHelp) {
      print(options.usage);
      return;
    }

    final CheckReporter? onCheck =
        options.verbose ? LoggerHelper.printVerbose : null;

    try {
      EagleEyeConfig configFile =
          await _repository.getAndCheckIfConfigFileExists();

      List<File> dartFiles = _repository.allDartFiles();

      String applicationName = _repository.getApplicationName();

      onCheck?.call(
        'Loaded ${configFile.items.length} rule(s) from '
        '${EagleEyeRepositoryImpl.configFileName}',
      );
      onCheck?.call('Application name: $applicationName');
      onCheck?.call('Found ${dartFiles.length} Dart file(s) in lib/');

      final EagleEyeMatcher matcher = EagleEyeMatcher(
        config: configFile,
        regexHelper: RegexHelper(),
        onCheck: onCheck,
      );

      List<Violation> errors = [];

      for (final file in dartFiles) {
        onCheck?.call('Checking ${file.path}');

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
            unit: result.unit,
            onCheck: onCheck,
          );
          result.unit.visitChildren(visitor);
        } else {
          onCheck?.call('  no rule matched; skipping file');
        }
      }

      onCheck?.call(
        'Checked ${dartFiles.length} file(s); '
        '${errors.length} violation(s) found',
      );

      if (errors.isNotEmpty) {
        final output = OutputRenderer().format(errors);
        print(output);
      }

      if (errors.isEmpty) {
        LoggerHelper.printSuccess('Verification finished');
      } else {
        exit(1);
      }
    } on EagleEyeException catch (e) {
      LoggerHelper.printError(e.message);
      exit(1);
    }
  }
}
