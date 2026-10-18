import 'package:eagle_eye/model/config_keys.dart';
import 'package:eagle_eye/model/exceptions/invalid_config_exception.dart';

/// Represents a single rule item in the Eagle Eye configuration file.
///
/// Each [EagleEyeConfigItem] defines dependency constraints for files
/// that match a specific [filePattern].
/// These constraints control which imports are allowed or forbidden
/// within that scope.
///
/// Configuration behavior:
/// - If [dependenciesAllowed] is `false`, the file cannot import anything.
/// - If [forbiddenDependencies] is provided, the file **cannot** import
///   any module matching those patterns.
/// - If [exclusiveDependencies] is provided, the file **can only** import
///   modules that match those patterns.
class EagleEyeConfigItem {
  /// If `false`, the file should not contain any import statements.
  bool? dependenciesAllowed = true;

  /// List of regex or wildcard patterns representing forbidden imports.
  List<String>? forbiddenDependencies;

  /// List of regex or wildcard patterns representing allowed imports.
  List<String>? exclusiveDependencies;

  /// Pattern used to identify which files this rule applies to.
  String filePattern;

  /// Optional human-readable name for this rule.
  String? name;

  /// Creates a new [EagleEyeConfigItem] instance with the given parameters.
  EagleEyeConfigItem({
    this.dependenciesAllowed,
    this.forbiddenDependencies,
    this.exclusiveDependencies,
    required this.filePattern,
    this.name,
  });

  /// Maps a single JSON object into an [EagleEyeConfigItem].
  ///
  /// Throws an [InvalidConfigException] when a required field is missing or
  /// when a field has an unexpected type.
  factory EagleEyeConfigItem.fromJson(Map<String, dynamic> json) {
    final dependenciesAllowed = _readDependenciesAllowed(json);
    final forbiddenDependencies = _readStringList(
      json,
      ConfigKeys.forbiddenDependenciesEagleItemKey,
    );
    final exclusiveDependencies = _readStringList(
      json,
      ConfigKeys.exclusiveDependenciesEagleItemKey,
    );
    final filePattern = _readFilePattern(json);
    final name = _readName(json);

    return EagleEyeConfigItem(
      dependenciesAllowed: dependenciesAllowed,
      forbiddenDependencies: forbiddenDependencies,
      exclusiveDependencies: exclusiveDependencies,
      filePattern: filePattern,
      name: name,
    );
  }

  static bool? _readDependenciesAllowed(Map<String, dynamic> json) {
    final key = ConfigKeys.dependenciesAllowedEagleItemKey;
    final value = json[key];
    if (value != null && value is! bool) {
      throw InvalidConfigException('The "$key" value must be a boolean.');
    }
    return value as bool?;
  }

  static List<String>? _readStringList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is! List || value.any((item) => item is! String)) {
      throw InvalidConfigException(
        'The "$key" value must be a list of strings.',
      );
    }
    return List<String>.from(value);
  }

  static String _readFilePattern(Map<String, dynamic> json) {
    final key = ConfigKeys.filePatternEagleItemKey;
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw InvalidConfigException(
        'The "$key" value is required and must be a non-empty string.',
      );
    }
    return value;
  }

  static String? _readName(Map<String, dynamic> json) {
    final key = ConfigKeys.nameEagleItemKey;
    final value = json[key];
    if (value != null && value is! String) {
      throw InvalidConfigException('The "$key" value must be a string.');
    }
    return value as String?;
  }
}
