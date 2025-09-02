import 'package:eagleeye/eagle_eye/model/error.dart';
import 'package:eagleeye/eagle_eye/model/software_unit.dart';

class ArchitectureViolationChecker {
  Map<String, List<String>> importViolationByFile;

  ArchitectureViolationChecker(this.importViolationByFile);

  Error? check(SoftwareUnit unit) {
    for (var pattern in importViolationByFile.keys) {
      if (_matchesPattern(unit.filePath, pattern)) {
        final violations = importViolationByFile[pattern]!;
        for (var violation in violations) {
          for (var import in unit.imports) {
            if (_matchesPattern(import, violation)) {
              return Error(
                filePath: unit.filePath,
                import: import,
                violation: violation,
              );
            }
          }
        }
      }
    }
    return null;
  }

  bool _matchesPattern(String text, String pattern) {
    final regex = RegExp(pattern.replaceAll('*', '.*'));
    return regex.hasMatch(text);
  }
}
