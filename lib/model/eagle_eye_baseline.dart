import 'package:eagle_eye/model/baseline_entry.dart';
import 'package:eagle_eye/model/exceptions/invalid_baseline_exception.dart';
import 'package:eagle_eye/model/violation.dart';

/// Represents the Eagle Eye baseline file.
///
/// The [EagleEyeBaseline] holds the list of [BaselineEntry]s that were known
/// when the baseline was generated. Any violation matching an entry is
/// suppressed, while unmatched violations are reported as new.
class EagleEyeBaseline {
  /// The current baseline format version.
  static const currentVersion = 1;

  static const _versionKey = 'version';
  static const _violationsKey = 'violations';

  /// The baseline format version the file was written with.
  final int version;

  /// The known violations recorded in the baseline.
  final List<BaselineEntry> entries;

  /// Creates a new [EagleEyeBaseline] with the given [entries].
  EagleEyeBaseline({
    this.version = currentVersion,
    required this.entries,
  });

  /// Builds a baseline from a list of [violations].
  ///
  /// Entries are deduplicated by [BaselineEntry.signature] and sorted so the
  /// generated file is deterministic.
  factory EagleEyeBaseline.fromViolations(List<Violation> violations) {
    final seen = <String>{};
    final entries = <BaselineEntry>[];
    for (final violation in violations) {
      final entry = BaselineEntry.fromViolation(violation);
      if (seen.add(entry.signature)) {
        entries.add(entry);
      }
    }
    entries.sort((a, b) => a.signature.compareTo(b.signature));

    return EagleEyeBaseline(entries: entries);
  }

  /// Maps a decoded JSON object into an [EagleEyeBaseline].
  ///
  /// Throws an [InvalidBaselineException] if the shape is invalid.
  factory EagleEyeBaseline.fromJson(Map<String, dynamic> json) {
    final version = json[_versionKey] as int? ?? currentVersion;
    final rawViolations = json[_violationsKey] as List<dynamic>? ?? [];

    final entries = rawViolations
        .map(
          (item) => BaselineEntry.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return EagleEyeBaseline(version: version, entries: entries);
  }

  /// Serializes this baseline into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      _versionKey: version,
      _violationsKey: entries.map((entry) => entry.toJson()).toList(),
    };
  }

  /// Returns `true` if [violation] is recorded in this baseline.
  bool contains(Violation violation) {
    return entries.contains(BaselineEntry.fromViolation(violation));
  }
}
