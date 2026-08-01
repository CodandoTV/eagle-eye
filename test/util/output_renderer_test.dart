import 'package:eagle_eye/model/violation.dart';
import 'package:eagle_eye/util/output_renderer.dart';
import 'package:test/test.dart';

void main() {
  group('OutputRenderer', () {
    late OutputRenderer renderer;

    setUp(() {
      renderer = OutputRenderer();
    });

    test('returns empty string for no violations', () {
      final result = renderer.format([]);

      expect(result, isEmpty);
    });

    test('formats single violation without ruleName', () {
      final violations = [
        Violation(
          ruleType: RuleType.forbiddenDependency,
          filePath: 'lib/src/foo.dart',
          lineNumber: 10,
          columnNumber: 5,
          importUri: 'package:bar/bar.dart',
          description: 'Forbidden dependency',
        ),
      ];

      final result = renderer.format(violations);

      expect(
        result,
        'lib/src/foo.dart\n'
        '  ✗ forbidden-dependency\n'
        "    • 10: import 'package:bar/bar.dart';\n"
        '\n'
        '✗ Verification failed: 1 errors in 1 files 🦅',
      );
    });

    test('formats single violation with ruleName', () {
      final violations = [
        Violation(
          ruleType: RuleType.noImportsAllowed,
          filePath: 'lib/src/bar.dart',
          lineNumber: 3,
          columnNumber: 1,
          importUri: 'dart:async',
          ruleName: 'core-layer',
          description: 'No imports allowed',
        ),
      ];

      final result = renderer.format(violations);

      expect(
        result,
        'lib/src/bar.dart\n'
        '  ✗ no-imports-allowed: "core-layer"\n'
        "    • 3: import 'dart:async';\n"
        '\n'
        '✗ Verification failed: 1 errors in 1 files 🦅',
      );
    });

    test('groups multiple violations in the same file', () {
      final violations = [
        Violation(
          ruleType: RuleType.forbiddenDependency,
          filePath: 'lib/src/foo.dart',
          lineNumber: 5,
          columnNumber: 1,
          importUri: 'package:bar/bar.dart',
          description: 'Forbidden dependency',
        ),
        Violation(
          ruleType: RuleType.noImportsAllowed,
          filePath: 'lib/src/foo.dart',
          lineNumber: 12,
          columnNumber: 1,
          importUri: 'package:baz/baz.dart',
          description: 'No imports allowed',
        ),
      ];

      final result = renderer.format(violations);

      expect(
        result,
        'lib/src/foo.dart\n'
        '  ✗ forbidden-dependency\n'
        "    • 5: import 'package:bar/bar.dart';\n"
        '  ✗ no-imports-allowed\n'
        "    • 12: import 'package:baz/baz.dart';\n"
        '\n'
        '✗ Verification failed: 2 errors in 1 files 🦅',
      );
    });

    test('groups and sorts violations across multiple files', () {
      final violations = [
        Violation(
          ruleType: RuleType.forbiddenDependency,
          filePath: 'lib/src/zzz.dart',
          lineNumber: 1,
          columnNumber: 1,
          importUri: 'package:x/x.dart',
          description: 'Forbidden dependency',
        ),
        Violation(
          ruleType: RuleType.exclusiveDependency,
          filePath: 'lib/src/aaa.dart',
          lineNumber: 2,
          columnNumber: 1,
          importUri: 'package:y/y.dart',
          description: 'Exclusive dependency',
        ),
      ];

      final result = renderer.format(violations);

      expect(
        result,
        'lib/src/aaa.dart\n'
        '  ✗ exclusive-dependency\n'
        "    • 2: import 'package:y/y.dart';\n"
        '\n'
        'lib/src/zzz.dart\n'
        '  ✗ forbidden-dependency\n'
        "    • 1: import 'package:x/x.dart';\n"
        '\n'
        '✗ Verification failed: 2 errors in 2 files 🦅',
      );
    });

    test('renders all three rule type labels', () {
      final violations = [
        Violation(
          ruleType: RuleType.noImportsAllowed,
          filePath: 'a.dart',
          lineNumber: 1,
          columnNumber: 1,
          importUri: 'dart:async',
          description: 'No imports allowed',
        ),
        Violation(
          ruleType: RuleType.forbiddenDependency,
          filePath: 'b.dart',
          lineNumber: 1,
          columnNumber: 1,
          importUri: 'dart:async',
          description: 'Forbidden dependency',
        ),
        Violation(
          ruleType: RuleType.exclusiveDependency,
          filePath: 'c.dart',
          lineNumber: 1,
          columnNumber: 1,
          importUri: 'dart:async',
          description: 'Exclusive dependency',
        ),
      ];

      final result = renderer.format(violations);

      expect(result, contains('no-imports-allowed'));
      expect(result, contains('forbidden-dependency'));
      expect(result, contains('exclusive-dependency'));
    });
  });
}
