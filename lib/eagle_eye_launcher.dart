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

class EagleEyeLauncher {
  late EagleEyeRepository _repository;

  EagleEyeLauncher() {
    final fileHelper = FileHelper();
    _repository = EagleEyeRepositoryImpl(
      fileHelper: fileHelper,
      jsonConverter: JsonConverter(),
    );
  }

  Future<void> launchEagleEye() async {
    EagleEyeConfig configFile =
        await _repository.getAndCheckIfConfigFileExists();
    List<File> dartFiles = _repository.allDartFiles();
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
