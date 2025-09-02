import 'dart:convert';
import 'dart:io';
import 'package:eagle_eye/architecture_violation_checker.dart';
import 'package:eagle_eye/logger_helper.dart';
import 'package:eagle_eye/model/error_info.dart';
import 'package:eagle_eye/software_unit_mapper.dart';

Future<void> main(List<String> args) async {
  final file = File('eagle_eye_config.json');
  if (!file.existsSync()) {
    LoggerHelper.printError('eagle_eye_config.json not found!');
    exit(1);
  }

  final content = file.readAsStringSync();
  final config = jsonDecode(content);

  Map<String, dynamic> importViolationsData = config['import_violations'];

  Map<String, List<String>> importViolationsByFile =
      _convertToMapOfListOfString(importViolationsData);

  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  final mapper = SoftwareUnitMapper();
  final units = await mapper.map(files);

  final checker = ArchitectureViolationChecker(importViolationsByFile);

  List<ErrorInfo> errors = [];

  for (var unit in units) {
    final error = checker.check(unit);
    if (error != null) {
      errors.add(error);
    }
  }

  if (errors.isNotEmpty) {
    LoggerHelper.printError('${errors.length} violations found');
    for (var error in errors) {
      LoggerHelper.printError(
          'Violation found in ${error.filePath}: ${error.import}');
    }
    exit(1);
  } else {
    LoggerHelper.printSuccess('No architecture violations found.');
  }
}

Map<String, List<String>> _convertToMapOfListOfString(
  Map<String, dynamic> input,
) {
  final Map<String, List<String>> output = {};

  input.forEach((key, value) {
    if (value is List) {
      output[key.toString()] = value.map((e) => e.toString()).toList();
    }
  });

  return output;
}
