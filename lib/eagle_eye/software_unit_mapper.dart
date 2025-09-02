import 'dart:io';

import 'package:eagleeye/eagle_eye/model/software_unit.dart';

class SoftwareUnitMapper {
  Future<List<SoftwareUnit>> map(List<File> files) async {
    final List<SoftwareUnit> units = [];
    for (var file in files) {
      final imports = await _extractImports(file);
      units.add(
        SoftwareUnit(
          filePath: file.path,
          imports: imports,
        ),
      );
    }
    return units;
  }

  Future<List<String>> _extractImports(File file) async {
    final List<String> imports = [];
    final lines = await file.readAsLines();

    for (final line in lines) {
      if (line.trim().startsWith('import')) {
        imports.add(line.trim());
      }
    }
    return imports;
  }
}
