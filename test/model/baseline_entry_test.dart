import 'package:eagle_eye/model/baseline_entry.dart';
import 'package:eagle_eye/model/exceptions/invalid_baseline_exception.dart';
import 'package:eagle_eye/model/violation.dart';
import 'package:test/test.dart';

void main() {
  group('BaselineEntry', () {
    test('fromViolation copies filePath, importUri and ruleType', () {
      const violation = Violation(
        ruleType: RuleType.forbiddenDependency,
        filePath: 'lib/src/foo.dart',
        lineNumber: 10,
        columnNumber: 5,
        importUri: 'package:app/bar.dart',
        description: 'Forbidden dependency',
      );

      final entry = BaselineEntry.fromViolation(violation);

      expect(entry.filePath, 'lib/src/foo.dart');
      expect(entry.importUri, 'package:app/bar.dart');
      expect(entry.ruleType, RuleType.forbiddenDependency);
    });

    test('signature ignores line and column numbers', () {
      const first = Violation(
        ruleType: RuleType.noImportsAllowed,
        filePath: 'lib/src/foo.dart',
        lineNumber: 1,
        columnNumber: 1,
        importUri: 'package:app/bar.dart',
        description: 'No imports allowed',
      );
      const shifted = Violation(
        ruleType: RuleType.noImportsAllowed,
        filePath: 'lib/src/foo.dart',
        lineNumber: 42,
        columnNumber: 9,
        importUri: 'package:app/bar.dart',
        description: 'No imports allowed',
      );

      final firstEntry = BaselineEntry.fromViolation(first);
      final shiftedEntry = BaselineEntry.fromViolation(shifted);

      expect(firstEntry, equals(shiftedEntry));
      expect(firstEntry.signature, equals(shiftedEntry.signature));
    });

    test('toJson produces the expected map', () {
      const entry = BaselineEntry(
        filePath: 'lib/src/foo.dart',
        importUri: 'package:app/bar.dart',
        ruleType: RuleType.exclusiveDependency,
      );

      expect(entry.toJson(), {
        'filePath': 'lib/src/foo.dart',
        'importUri': 'package:app/bar.dart',
        'ruleType': 'exclusiveDependency',
      });
    });

    test('fromJson round-trips a serialized entry', () {
      const entry = BaselineEntry(
        filePath: 'lib/src/foo.dart',
        importUri: 'package:app/bar.dart',
        ruleType: RuleType.forbiddenDependency,
      );

      final restored = BaselineEntry.fromJson(entry.toJson());

      expect(restored, equals(entry));
    });

    test('supports a null importUri', () {
      const entry = BaselineEntry(
        filePath: 'lib/src/foo.dart',
        importUri: null,
        ruleType: RuleType.noImportsAllowed,
      );

      expect(BaselineEntry.fromJson(entry.toJson()), equals(entry));
    });

    test('throws InvalidBaselineException for an unknown rule type', () {
      final json = {
        'filePath': 'lib/src/foo.dart',
        'importUri': 'package:app/bar.dart',
        'ruleType': 'notARealRule',
      };

      expect(
        () => BaselineEntry.fromJson(json),
        throwsA(isA<InvalidBaselineException>()),
      );
    });

    test('throws InvalidBaselineException when filePath is missing', () {
      final json = {
        'importUri': 'package:app/bar.dart',
        'ruleType': 'forbiddenDependency',
      };

      expect(
        () => BaselineEntry.fromJson(json),
        throwsA(isA<InvalidBaselineException>()),
      );
    });
  });
}
