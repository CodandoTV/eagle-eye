import 'dart:io';

import 'package:eagle_eye/data/eagle_eye_repository.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';
import 'package:eagle_eye/model/violation.dart';
import 'package:eagle_eye/service_locator.dart';
import 'package:eagle_eye/util/check_reporter.dart';
import 'package:eagle_eye/util/cli_options.dart';
import 'package:eagle_eye/util/logger_helper.dart';

/// The main launcher for Eagle Eye architecture validation.
///
/// [EagleEyeLauncher] coordinates the analysis of a Dart project using
/// the Eagle Eye tool. It performs the following steps:
/// 1. Parses the command-line arguments.
/// 2. Loads the configuration file (`eagle_eye_config.json`) via
/// [EagleEyeRepository].
/// 3. Collects all Dart files in the `lib/` folder.
/// 4. Determines the application name from `pubspec.yaml`.
/// 5. Validates the configuration with [EagleEyeConfigValidator], rejecting
/// invalid rules and files matched by more than one rule.
/// 6. Uses [EagleEyeMatcher] to find which rules apply to each file.
/// 7. Uses [EagleEyeVisitor] to analyze imports and collect violations.
/// 8. Logs errors using [LoggerHelper] and exits with a non-zero code if
/// violations exist.
class EagleEyeLauncher {
  final ServiceLocator _locator;

  /// Creates a new [EagleEyeLauncher].
  ///
  /// When [serviceLocator] is omitted, a default [ServiceLocator] is used.
  EagleEyeLauncher({ServiceLocator? serviceLocator})
    : _locator = serviceLocator ?? ServiceLocator();

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
      options = _locator.parseCliOptions(args);
    } on FormatException catch (e) {
      LoggerHelper.printError(e.message);
      exit(1);
    }

    if (options.showHelp) {
      print(options.usage);
      return;
    }

    final CheckReporter? onCheck = options.verbose
        ? LoggerHelper.printVerbose
        : null;

    try {
      EagleEyeConfig configFile = await _locator.repository
          .getAndCheckIfConfigFileExists();

      List<String> dartPaths = _locator.repository.allDartPaths();

      String applicationName = _locator.repository.getApplicationName();

      onCheck?.call(
        'Loaded ${configFile.items.length} rule(s) from '
        '${EagleEyeRepositoryImpl.configFileName}',
      );
      onCheck?.call('Application name: $applicationName');
      onCheck?.call('Found ${dartPaths.length} Dart file(s) in lib/');

      _locator
          .createConfigValidator(onCheck: onCheck)
          .validate(config: configFile, filePaths: dartPaths);

      final matcher = _locator.createMatcher(
        config: configFile,
        onCheck: onCheck,
      );

      List<Violation> errors = [];

      for (final path in dartPaths) {
        onCheck?.call('Checking $path');

        final unit = _locator.dartSourceLoader.load(path);
        EagleEyeConfigItem? eagleEyeItem = matcher.find(path);
        if (eagleEyeItem != null) {
          final visitor = _locator.createVisitor(
            configItem: eagleEyeItem,
            filePath: path,
            applicationName: applicationName,
            unit: unit,
            errorCallback: (error) => errors.add(error),
            onCheck: onCheck,
          );
          unit.visitChildren(visitor);
        } else {
          onCheck?.call('  no rule matched; skipping file');
        }
      }

      onCheck?.call(
        'Checked ${dartPaths.length} file(s); '
        '${errors.length} violation(s) found',
      );

      if (errors.isNotEmpty) {
        final output = _locator.outputRenderer.format(errors);
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
