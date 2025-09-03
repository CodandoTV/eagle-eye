import 'package:eagle_eye/model/error_info.dart';
import 'package:eagle_eye/model/software_unit.dart';
import 'package:eagle_eye/rules/architecture_rule_checker.dart';

class DoNotWithRuleChecker implements ArchitectureRuleChecker {
  Map<String, List<String>> notWithImports;

  DoNotWithRuleChecker({required this.notWithImports});

  @override
  ErrorInfo? check({required SoftwareUnit softwareUnit}) {
    // Find the specific rules for the target fileNamePattern
    for (var fileNamePattern in notWithImports.keys) {

      // Check if the target softwareUnit is the one we need to evaluate
      if (_matchesPattern(softwareUnit.filePath, fileNamePattern)) {

        // Get the import violations for the specific target 
        final violations = notWithImports[fileNamePattern]!;

        for (var violation in violations) {

          for (var import in softwareUnit.imports) {

            // Check if the import is a violation
            if (_matchesPattern(import, violation)) {
              return ErrorInfo(
                filePath: softwareUnit.filePath,
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
