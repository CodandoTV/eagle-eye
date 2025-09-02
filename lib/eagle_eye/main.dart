import 'dart:io';

import 'package:eagleeye/eagle_eye/architecture_violation_checker.dart';
import 'package:eagleeye/eagle_eye/software_unit_mapper.dart';

Map<String, List<String>> importViolationByFile = {
  '*screen.dart': ['*data*', '*domain*'],
  '*widget.dart': ['*data*', '*domain*'],
};

const red = '\x1B[31m';
const green = '\x1B[32m';
const reset = '\x1B[0m';

Future<void> check(String projectPath) async {
  final files = Directory('$projectPath/lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  final mapper = SoftwareUnitMapper();
  final units = await mapper.map(files);

  final checker = ArchitectureViolationChecker();
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
