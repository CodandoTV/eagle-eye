import 'package:eagle_eye/model/exceptions/invalid_baseline_exception.dart';
import 'package:eagle_eye/model/violation.dart';

/// Represents a single known violation stored in the Eagle Eye baseline.
///
/// A [BaselineEntry] is identified by the combination of its [filePath],
/// [ruleType], and [importUri]. Line and column numbers are deliberately
/// excluded so that adding code above a known violation does not resurface
/// it as a new one.
class BaselineEntry {
  static const _filePathKey = 'filePath';
  static const _importUriKey = 'importUri';
  static const _ruleTypeKey = 'ruleType';

  /// Path of the file containing the violation.
  final String filePath;

  /// The import URI that triggered the violation, if applicable.
  final String? importUri;

  /// Which rule type was violated.
  final RuleType ruleType;

  /// Creates a new [BaselineEntry] with the given properties.
  const BaselineEntry({
    required this.filePath,
    required this.importUri,
    required this.ruleType,
  });

  /// Builds a [BaselineEntry] from a [Violation].
  factory BaselineEntry.fromViolation(Violation violation) {
    return BaselineEntry(
      filePath: violation.filePath,
      importUri: violation.importUri,
      ruleType: violation.ruleType,
    );
  }

  /// Maps a single JSON object into a [BaselineEntry].
  ///
  /// Throws an [InvalidBaselineException] if required fields are missing or
  /// the rule type is unknown.
  factory BaselineEntry.fromJson(Map<String, dynamic> json) {
    try {
      return BaselineEntry(
        filePath: json[_filePathKey] as String,
        importUri: json[_importUriKey] as String?,
        ruleType: _ruleTypeFromName(json[_ruleTypeKey] as String),
      );
    } catch (_) {
      throw InvalidBaselineException();
    }
  }

  /// Serializes this entry into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      _filePathKey: filePath,
      _importUriKey: importUri,
      _ruleTypeKey: ruleType.name,
    };
  }

  /// Stable identity used to match entries and deduplicate the baseline.
  String get signature => '$filePath|${ruleType.name}|${importUri ?? ''}';

  @override
  bool operator ==(Object other) {
    return other is BaselineEntry &&
        other.filePath == filePath &&
        other.importUri == importUri &&
        other.ruleType == ruleType;
  }

  @override
  int get hashCode => Object.hash(filePath, importUri, ruleType);

  static RuleType _ruleTypeFromName(String name) {
    return RuleType.values.firstWhere((type) => type.name == name);
  }
}
