import 'dart:io';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:eagle_eye/eagle_eye_matcher.dart';
import 'package:eagle_eye/file_helper.dart';
import 'package:eagle_eye/logger_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/error_info.dart';
import 'package:eagle_eye/resources.dart';
import 'package:eagle_eye/rules/eagle_eye_visitor.dart';

Future<void> main() async {
  EagleEyeConfig configFile = await FileHelper.getAndCheckIfConfigFileExists(
    Resources.configFile,
  );
  Directory libsDirectory = FileHelper.getAndCheckIfLibsDirectoryExists(
    Resources.libsFolderName,
  );

  final dartFiles = FileHelper.allDartFiles(libsDirectory);
  final EagleEyeMatcher matcher = EagleEyeMatcher(configFile);
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
    LoggerHelper.printError('Verification failed with ${errors.length} errors');
    exit(1);
  }
}
