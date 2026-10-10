import 'package:eagle_eye/model/baseline_entry.dart';
import 'package:eagle_eye/model/eagle_eye_baseline.dart';
import 'package:eagle_eye/model/violation.dart';

/// The outcome of applying a baseline to a list of violations.
class BaselineResult {
  /// Violations that are not present in the baseline.
  final List<Violation> newViolations;

  /// How many violations were suppressed by the baseline.
  final int suppressedCount;

  /// Baseline entries that no longer match any violation.
  final List<BaselineEntry> staleEntries;

  /// Creates a new [BaselineResult].
  BaselineResult({
    required this.newViolations,
    required this.suppressedCount,
    required this.staleEntries,
  });
}

/// Filters violations against a baseline, splitting them into new violations
/// and suppressions while tracking obsolete baseline entries.
class BaselineFilter {
  /// Applies [baseline] to [violations].
  ///
  /// A violation is suppressed when its signature (`filePath`, `ruleType`,
  /// `importUri`) matches an entry in the baseline. Baseline entries whose
  /// signature never matches are returned as [BaselineResult.staleEntries].
  BaselineResult apply({
    required List<Violation> violations,
    required EagleEyeBaseline baseline,
  }) {
    final matchedSignatures = <String>{};
    final newViolations = <Violation>[];

    for (final violation in violations) {
      final entry = BaselineEntry.fromViolation(violation);
      if (baseline.contains(violation)) {
        matchedSignatures.add(entry.signature);
      } else {
        newViolations.add(violation);
      }
    }

    final staleSignatures = <String>{};
    final staleEntries = <BaselineEntry>[];
    for (final entry in baseline.entries) {
      final isStale = matchedSignatures.contains(entry.signature) == false;
      if (isStale && staleSignatures.add(entry.signature)) {
        staleEntries.add(entry);
      }
    }

    return BaselineResult(
      newViolations: newViolations,
      suppressedCount: violations.length - newViolations.length,
      staleEntries: staleEntries,
    );
  }
}
