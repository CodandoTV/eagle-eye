import 'dart:io';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:eagle_eye/file_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/resources.dart';
import 'package:eagle_eye/rules/no_dependency_rule_visitor.dart';

Future<void> main() async {
  EagleEyeConfig configFile = await FileHelper.getAndCheckIfConfigFileExists(
    Resources.configFile,
  );
  Directory libsDirectory = FileHelper.getAndCheckIfLibsDirectoryExists(
    Resources.libsFolderName,
  );

  final dartFiles = FileHelper.allDartFiles(libsDirectory);

  for (final file in dartFiles) {
    final result = parseFile(
      path: file.path,
      featureSet: FeatureSet.latestLanguageVersion(),
    );
    if (file.path.contains('tasks_viewmodel.dart')) {
      result.unit.visitChildren(NoDependencyRuleVisitor(file.path));
    }
  }
}
