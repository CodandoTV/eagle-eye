import 'package:eagle_eye/analyzer/baseline_filter.dart';
import 'package:eagle_eye/model/eagle_eye_baseline.dart';
import 'package:eagle_eye/model/violation.dart';
import 'package:test/test.dart';

Violation _violation({
  required String filePath,
  required String importUri,
  RuleType ruleType = RuleType.forbiddenDependency,
  int lineNumber = 1,
}) {
  return Violation(
    ruleType: ruleType,
    filePath: filePath,
    lineNumber: lineNumber,
    columnNumber: 1,
    importUri: importUri,
    description: 'violation',
  );
}

void main() {
  group('BaselineFilter', () {
    late BaselineFilter filter;

    setUp(() {
      filter = BaselineFilter();
    });

    test('suppresses violations present in the baseline', () {
      final violation =
          _violation(filePath: 'lib/a.dart', importUri: 'package:app/b.dart');
      final baseline = EagleEyeBaseline.fromViolations([violation]);

      final result = filter.apply(
        violations: [violation],
        baseline: baseline,
      );

      expect(result.newViolations, isEmpty);
      expect(result.suppressedCount, 1);
      expect(result.staleEntries, isEmpty);
    });

    test('reports violations missing from the baseline as new', () {
      final known =
          _violation(filePath: 'lib/a.dart', importUri: 'package:app/b.dart');
      final fresh =
          _violation(filePath: 'lib/c.dart', importUri: 'package:app/d.dart');
      final baseline = EagleEyeBaseline.fromViolations([known]);

      final result = filter.apply(
        violations: [known, fresh],
        baseline: baseline,
      );

      expect(result.newViolations, equals([fresh]));
      expect(result.suppressedCount, 1);
    });

    test('flags baseline entries that no longer match as stale', () {
      final removed =
          _violation(filePath: 'lib/a.dart', importUri: 'package:app/b.dart');
      final baseline = EagleEyeBaseline.fromViolations([removed]);

      final result = filter.apply(violations: [], baseline: baseline);

      expect(result.newViolations, isEmpty);
      expect(result.suppressedCount, 0);
      expect(result.staleEntries, equals(baseline.entries));
    });

    test('treats every violation as new with an empty baseline', () {
      final violation =
          _violation(filePath: 'lib/a.dart', importUri: 'package:app/b.dart');
      final baseline = EagleEyeBaseline(entries: []);

      final result = filter.apply(
        violations: [violation],
        baseline: baseline,
      );

      expect(result.newViolations, equals([violation]));
      expect(result.suppressedCount, 0);
      expect(result.staleEntries, isEmpty);
    });

    test('matches violations regardless of their line number', () {
      final known = _violation(
        filePath: 'lib/a.dart',
        importUri: 'package:app/b.dart',
        lineNumber: 4,
      );
      final shifted = _violation(
        filePath: 'lib/a.dart',
        importUri: 'package:app/b.dart',
        lineNumber: 99,
      );
      final baseline = EagleEyeBaseline.fromViolations([known]);

      final result = filter.apply(
        violations: [shifted],
        baseline: baseline,
      );

      expect(result.newViolations, isEmpty);
      expect(result.suppressedCount, 1);
      expect(result.staleEntries, isEmpty);
    });
  });
}
