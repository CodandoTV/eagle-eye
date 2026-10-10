import 'package:eagle_eye/model/baseline_entry.dart';
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
  group('EagleEyeBaseline', () {
    test('fromViolations deduplicates entries with the same signature', () {
      final baseline = EagleEyeBaseline.fromViolations([
        _violation(filePath: 'lib/a.dart', importUri: 'package:app/b.dart'),
        _violation(
          filePath: 'lib/a.dart',
          importUri: 'package:app/b.dart',
          lineNumber: 20,
        ),
      ]);

      expect(baseline.entries, hasLength(1));
    });

    test('fromViolations sorts entries by signature', () {
      final baseline = EagleEyeBaseline.fromViolations([
        _violation(filePath: 'lib/z.dart', importUri: 'package:app/z.dart'),
        _violation(filePath: 'lib/a.dart', importUri: 'package:app/a.dart'),
      ]);

      expect(
        baseline.entries.map((entry) => entry.filePath).toList(),
        ['lib/a.dart', 'lib/z.dart'],
      );
    });

    test('contains returns true for a recorded violation', () {
      final violation =
          _violation(filePath: 'lib/a.dart', importUri: 'package:app/b.dart');
      final baseline = EagleEyeBaseline.fromViolations([violation]);

      expect(baseline.contains(violation), isTrue);
    });

    test('contains returns false for an unknown violation', () {
      final baseline = EagleEyeBaseline.fromViolations([
        _violation(filePath: 'lib/a.dart', importUri: 'package:app/b.dart'),
      ]);

      final unknown =
          _violation(filePath: 'lib/c.dart', importUri: 'package:app/d.dart');

      expect(baseline.contains(unknown), isFalse);
    });

    test('toJson and fromJson round-trip', () {
      final baseline = EagleEyeBaseline.fromViolations([
        _violation(filePath: 'lib/a.dart', importUri: 'package:app/b.dart'),
      ]);

      final restored = EagleEyeBaseline.fromJson(baseline.toJson());

      expect(restored.version, EagleEyeBaseline.currentVersion);
      expect(restored.entries, equals(baseline.entries));
    });

    test('fromJson defaults to an empty list when violations is missing', () {
      final baseline = EagleEyeBaseline.fromJson({'version': 1});

      expect(baseline.entries, isEmpty);
    });

    test('fromJson defaults to the current version when missing', () {
      final baseline = EagleEyeBaseline.fromJson({'violations': []});

      expect(baseline.version, EagleEyeBaseline.currentVersion);
    });

    test('serializes entries as JSON maps', () {
      const entry = BaselineEntry(
        filePath: 'lib/a.dart',
        importUri: 'package:app/b.dart',
        ruleType: RuleType.forbiddenDependency,
      );
      final baseline = EagleEyeBaseline(entries: [entry]);

      expect(baseline.toJson(), {
        'version': EagleEyeBaseline.currentVersion,
        'violations': [entry.toJson()],
      });
    });
  });
}
