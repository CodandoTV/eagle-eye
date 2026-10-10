import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:eagle_eye/analyzer/baseline_filter.dart';
import 'package:eagle_eye/analyzer/eagle_eye_matcher.dart';
import 'package:eagle_eye/analyzer/eagle_eye_visitor.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/data/eagle_eye_repository.dart';
import 'package:eagle_eye/data/file_helper.dart';
import 'package:eagle_eye/data/json_converter.dart';
import 'package:eagle_eye/model/eagle_eye_baseline.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';
import 'package:eagle_eye/model/violation.dart';
import 'package:eagle_eye/util/logger_helper.dart';
import 'package:eagle_eye/util/output_renderer.dart';

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
  ///
  /// When [updateBaseline] is `true`, the collected violations are written to
  /// `eagle_eye_baseline.json` and the process finishes successfully.
  /// Otherwise, violations recorded in an existing baseline are suppressed
  /// and only new violations cause a non-zero exit code.
  Future<void> launchEagleEye({bool updateBaseline = false}) async {
    try {
      EagleEyeConfig configFile =
          await _repository.getAndCheckIfConfigFileExists();

      List<File> dartFiles = _repository.allDartFiles();

      String applicationName = _repository.getApplicationName();

      final EagleEyeMatcher matcher = EagleEyeMatcher(
        config: configFile,
        regexHelper: RegexHelper(),
      );

      List<Violation> errors = _collectViolations(
        dartFiles: dartFiles,
        matcher: matcher,
        applicationName: applicationName,
      );

      if (updateBaseline) {
        await _writeBaseline(errors);
        return;
      }

      final baseline = await _repository.getBaselineIfExists();
      if (baseline == null) {
        _reportWithoutBaseline(errors);
        return;
      }

      _reportWithBaseline(errors, baseline);
    } on EagleEyeException catch (e) {
      LoggerHelper.printError(e.message);
      exit(1);
    }
  }

  List<Violation> _collectViolations({
    required List<File> dartFiles,
    required EagleEyeMatcher matcher,
    required String applicationName,
  }) {
    List<Violation> errors = [];

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
          unit: result.unit,
        );
        result.unit.visitChildren(visitor);
      }
    }

    return errors;
  }

  Future<void> _writeBaseline(List<Violation> errors) async {
    final baseline = EagleEyeBaseline.fromViolations(errors);
    await _repository.saveBaseline(baseline);
    LoggerHelper.printSuccess(
      'Baseline written with ${baseline.entries.length} violations',
    );
  }

  void _reportWithoutBaseline(List<Violation> errors) {
    if (errors.isEmpty) {
      LoggerHelper.printSuccess('Verification finished');
      return;
    }

    print(OutputRenderer().format(errors));
    exit(1);
  }

  void _reportWithBaseline(
    List<Violation> errors,
    EagleEyeBaseline baseline,
  ) {
    final result = BaselineFilter().apply(
      violations: errors,
      baseline: baseline,
    );

    if (result.newViolations.isEmpty) {
      LoggerHelper.printSuccess('Verification finished');
    } else {
      print(OutputRenderer().format(result.newViolations));
    }

    if (result.suppressedCount > 0) {
      LoggerHelper.printInfo(
        '${result.suppressedCount} known violations suppressed by baseline',
      );
    }

    if (result.staleEntries.isNotEmpty) {
      LoggerHelper.printWarning(
        '${result.staleEntries.length} baseline entries are obsolete; '
        'run with --baseline to prune them.',
      );
    }

    if (result.newViolations.isNotEmpty) {
      exit(1);
    }
  }
}
