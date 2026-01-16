import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/error_info.dart';

/// A rule checker that ensures a file imports **only allowed dependencies**.
///
/// The [ExclusiveDependenciesRuleChecker] uses a [RegexHelper] to verify that
/// each import directive matches all the allowed dependency patterns.
/// If an import does not match any of the patterns, an [ErrorInfo]
/// describing the violation is returned.
class ExclusiveDependenciesRuleChecker {
  /// Helper class used for regex-based pattern matching.
  RegexHelper regexHelper;

  /// Creates a new [ExclusiveDependenciesRuleChecker]
  /// instance with the given [regexHelper].
  ExclusiveDependenciesRuleChecker(this.regexHelper);

  /// Checks if the given [importDirective] conforms to the specified
  /// [justWithPatterns] for the provided [filePath].
  ///
  /// - [justWithPatterns]: list of regex patterns representing allowed imports
  /// - [importDirective]: The import statement to validate
  /// - [filePath]: The path of the file being analyzed
  ///
  /// Returns an [ErrorInfo] if the import does **not** match any allowed
  /// pattern, or `null` if it passes the validation.
  ErrorInfo? check({
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
        return ErrorInfo(
          filePath: filePath,
          errorMessage: '$filePath should depends only on $justWithPatterns',
        );
      }
    }
    return null;
  }
}
