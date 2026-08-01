import 'package:eagle_eye/analyzer/regex_helper.dart';

/// Validates whether a file imports disallowed dependencies.
///
/// Tests each import against a list of forbidden dependency patterns.
/// Returns a description string if a violation is found.
class ForbiddenDependenciesRuleChecker {
  /// Helper used for regex-based pattern matching.
  RegexHelper regexHelper;

  /// Creates a new [ForbiddenDependenciesRuleChecker] with the given
  /// [regexHelper].
  ForbiddenDependenciesRuleChecker(this.regexHelper);

  /// Checks if [importDirective] violates any of [noDepsWithPatterns]
  /// for the given [filePath].
  ///
  /// Returns a violation description if a pattern matches, or `null`
  /// if all checks pass.
  String? check({
    required List<String> noDepsWithPatterns,
    required String importDirective,
    required String filePath,
  }) {
    for (var noDepsWithItem in noDepsWithPatterns) {
      var matches = regexHelper.matchesPattern(
        importDirective,
        noDepsWithItem,
      );
      if (matches == true) {
        return '$filePath should not depends on $importDirective';
      }
    }
    return null;
  }
}
