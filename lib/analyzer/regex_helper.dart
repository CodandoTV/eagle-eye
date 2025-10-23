/// A utility class that simplifies regex-based pattern matching.
///
/// The [RegexHelper] supports wildcard (`*`) expansion, converting it to
/// a valid regular expression (`.*`) before testing.
/// It’s mainly used by rule checkers to validate imports and file paths.
class RegexHelper {
  /// Checks if the given [text] matches the provided [pattern].
  ///
  /// The [pattern] may contain `*` wildcards, which are automatically
  /// translated into regex equivalents (`.*`).
  ///
  /// Returns `true` if the [text] matches the pattern; otherwise `false`.
  bool matchesPattern(String text, String pattern) {
    final regex = RegExp(pattern.replaceAll('*', '.*'));
    return regex.hasMatch(text);
  }
}
