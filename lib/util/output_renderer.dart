import 'package:eagle_eye/model/violation.dart';

/// Formats a list of [Violation] objects into a human-readable string.
///
/// Violations are grouped by file path, with each violation showing its
/// rule type, optional rule name, line number, and the offending import.
class OutputRenderer {
  static const _eagleEmoji = '\u{1F985}';

  /// Formats [violations] into a grouped string representation.
  ///
  /// Returns an empty string if there are no violations.
  String format(List<Violation> violations) {
    if (violations.isEmpty) {
      return '';
    }

    final grouped = <String, List<Violation>>{};
    for (final v in violations) {
      grouped.putIfAbsent(v.filePath, () => []).add(v);
    }

    final buffer = StringBuffer();
    final filePaths = grouped.keys.toList()..sort();

    for (final filePath in filePaths) {
      buffer.writeln(filePath);
      for (final v in grouped[filePath]!) {
        buffer.write('  \u2717 ${_ruleTypeLabel(v.ruleType)}');
        if (v.ruleName != null) {
          buffer.write(': "${v.ruleName}"');
        }
        buffer.writeln();
        final importLine = '    \u2022 ${v.lineNumber}: '
            "import '${v.importUri}';";
        buffer.writeln(importLine);
      }
      buffer.writeln();
    }

    final fileCount = grouped.length;
    final errorCount = violations.length;
    final summary = '\u2717 Verification failed: $errorCount errors '
        'in $fileCount files $_eagleEmoji';
    buffer.write(summary);

    return buffer.toString();
  }

  String _ruleTypeLabel(RuleType type) {
    switch (type) {
      case RuleType.noImportsAllowed:
        return 'no-imports-allowed';
      case RuleType.forbiddenDependency:
        return 'forbidden-dependency';
      case RuleType.exclusiveDependency:
        return 'exclusive-dependency';
    }
  }
}
