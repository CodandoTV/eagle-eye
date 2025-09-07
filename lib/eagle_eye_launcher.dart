import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:eagle_eye/analyzer/eagle_eye_matcher.dart';
import 'package:eagle_eye/analyzer/eagle_eye_visitor.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/constants.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/error_info.dart';
import 'package:eagle_eye/util/file_helper.dart';
import 'package:eagle_eye/util/logger_helper.dart';

class EagleEyeLauncher {
  final LoggerHelper _loggerHelper = LoggerHelper(debug: true);
  late FileHelper _fileHelper;

  EagleEyeLauncher() {
    _fileHelper = FileHelper(loggerHelper: _loggerHelper);
  }

  Future<void> launchEagleEye() async {
    EagleEyeConfig configFile = await _fileHelper.getAndCheckIfConfigFileExists(
      Constants.configFile,
    );
    Directory libsDirectory = _fileHelper.getAndCheckIfLibsDirectoryExists(
      Constants.libsFolderName,
    );

    final dartFiles = _fileHelper.allDartFiles(libsDirectory);
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
      _loggerHelper.printError(
        '${errorInfoItem.errorMessage} - ${errorInfoItem.filePath}',
      );
    }

    if (errors.isNotEmpty) {
      _loggerHelper
          .printError('Verification failed with ${errors.length} errors');
      exit(1);
    }
  }
}
