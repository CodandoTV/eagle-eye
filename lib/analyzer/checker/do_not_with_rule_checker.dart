import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/error_info.dart';

/// A rule checker that validates whether a file imports disallowed dependencies
///
/// The [DoNotWithRuleChecker] uses a [RegexHelper] to test import directives
/// against a list of forbidden dependency patterns. If a match is found,
/// an [ErrorInfo] is returned describing the violation.
class DoNotWithRuleChecker {
  /// Helper class used for regex-based pattern matching
  RegexHelper regexHelper;

  /// Creates a new [DoNotWithRuleChecker] instance with the given [regexHelper]
  DoNotWithRuleChecker(this.regexHelper);

  /// Checks if the given [importDirective] violates any of the provided
  /// [noDepsWithPatterns] for the specified [filePath].
  ///
  /// - [noDepsWithPatterns]: A list of regex patterns representing
  ///   dependencies that should not be imported.
  /// - [importDirective]: The import statement to validate.
  /// - [filePath]: The path of the file containing the import.
  ///
  /// Returns an [ErrorInfo] if the import violates a rule, or `null` if all
  /// checks pass.
  ErrorInfo? check({
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
        return ErrorInfo(
          filePath: filePath,
          errorMessage: '$filePath should not depends on $importDirective',
        );
      }
    }
    return null;
  }
}
