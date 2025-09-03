import 'package:eagle_eye/model/error_info.dart';
import 'package:eagle_eye/model/software_unit.dart';
import 'package:eagle_eye/rules/architecture_rule_checker.dart';

class JustWithRuleChecker implements ArchitectureRuleChecker {
  Map<String, List<String>> justWithImports;

  JustWithRuleChecker({required this.justWithImports});

  @override
  ErrorInfo? check({required SoftwareUnit softwareUnit}) {
    // Find the specific rules for the target fileNamePattern
    for (var fileNamePattern in justWithImports.keys) {
      // Check if the target softwareUnit is the one we need to evaluate
      if (_matchesPattern(softwareUnit.filePath, fileNamePattern)) {
        // Get the valid imports for the specific target
        final validImports = justWithImports[fileNamePattern]!;
        for (var import in softwareUnit.imports) {
          for (var validImport in validImports) {
            // First invalid import returns an error
            if (_matchesPattern(import, validImport) == false) {
              return ErrorInfo(
                filePath: softwareUnit.filePath,
                import: import,
                violation: 'It is not a valid import',
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
