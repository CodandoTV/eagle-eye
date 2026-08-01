import 'package:eagle_eye/analyzer/regex_helper.dart';

/// Validates whether a file imports only allowed dependencies.
///
/// Tests each import against a list of exclusive (allow-only) patterns.
/// Returns a description string if a violation is found.
class ExclusiveDependenciesRuleChecker {
  /// Helper used for regex-based pattern matching.
  RegexHelper regexHelper;

  /// Creates a new [ExclusiveDependenciesRuleChecker] with the given
  /// [regexHelper].
  ExclusiveDependenciesRuleChecker(this.regexHelper);

  /// Checks if [importDirective] conforms to the specified
  /// [justWithPatterns] for the given [filePath].
  ///
  /// Returns a violation description if the import does not match any
  /// allowed pattern, or `null` if it passes validation.
  String? check({
    required List<String> justWithPatterns,
    required String importDirective,
    required String filePath,
  }) {
    for (var justWithItem in justWithPatterns) {
      var matches = regexHelper.matchesPattern(
        importDirective,
        justWithItem,
      );
      if (matches == false) {
        return '$filePath should depends only on $justWithPatterns';
      }
    }
    return null;
  }
}
