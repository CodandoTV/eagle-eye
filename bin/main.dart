import 'dart:convert';
import 'dart:io';
import 'package:eagle_eye/architecture_violation_checker.dart';
import 'package:eagle_eye/software_unit_mapper.dart';

const red = '\x1B[31m';
const green = '\x1B[32m';
const reset = '\x1B[0m';

Future<void> main(List<String> args) async {
  final file = File('eagle_eye_config.json');
  if (!file.existsSync()) {
    print('${red}eagle_eye_config.json not found!');
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

  var hasAnyError = false;
  for (var unit in units) {
    final error = checker.check(unit);
    if (error != null) {
      print('${red}Architecture violation in ${error.filePath}: '
          '${error.import} which violates rule ${error.violation}${reset}');
      hasAnyError = true;
    }
  }

  if (hasAnyError) {
    exit(1);
  } else {
    print('${green}No architecture violations found.${reset}');
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
