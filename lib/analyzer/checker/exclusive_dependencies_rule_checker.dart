import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/util/check_reporter.dart';

/// Validates whether a file imports only allowed dependencies.
///
/// An import is valid when it matches **any** of the exclusive (allow-only)
/// patterns. A file that imports nothing is also valid, since there is no
/// import to check. Returns a description string if a violation is found.
class ExclusiveDependenciesRuleChecker {
  /// Helper used for regex-based pattern matching.
  RegexHelper regexHelper;

  /// Optional callback used to report each pattern checked.
  final CheckReporter? onCheck;

  /// Creates a new [ExclusiveDependenciesRuleChecker] with the given
  /// [regexHelper] and optional [onCheck] reporter.
  ExclusiveDependenciesRuleChecker(this.regexHelper, {this.onCheck});

  /// Checks if [importDirective] conforms to the specified
  /// [justWithPatterns] for the given [filePath].
  ///
  /// Returns `null` as soon as the import matches any allowed pattern, or a
  /// violation description if it matches none of them.
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
      onCheck?.call(
        '    allowed pattern "$justWithItem": '
        '${matches ? 'match -> allowed' : 'no match'}',
      );
      if (matches == true) {
        return null;
      }
    }
    return '$filePath should depend only on $justWithPatterns';
  }
}
