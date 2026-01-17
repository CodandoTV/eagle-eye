import 'package:eagle_eye/model/config_keys.dart';

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

  /// Creates a new [EagleEyeConfigItem] instance with the given parameters.
  EagleEyeConfigItem({
    this.dependenciesAllowed,
    this.forbiddenDependencies,
    this.exclusiveDependencies,
    required this.filePattern,
  });

  /// Maps a single JSON object into an [EagleEyeConfigItem].
  ///
  /// Handles missing or invalid fields gracefully by assigning `null`
  /// where appropriate.
  factory EagleEyeConfigItem.fromJson(Map<String, dynamic> json) {
    bool? dependenciesAllowed =
        json[ConfigKeys.dependenciesAllowedEagleItemKey];

    List<String>? forbiddenDependencies;
    try {
      forbiddenDependencies = List<String>.from(
        json[ConfigKeys.forbiddenDependenciesEagleItemKey] as List<dynamic>,
      );
    } catch (e) {
      forbiddenDependencies = null;
    }

    List<String>? exclusiveDependencies;
    try {
      exclusiveDependencies = List<String>.from(
        json[ConfigKeys.exclusiveDependenciesEagleItemKey] as List<dynamic>,
      );
    } catch (e) {
      exclusiveDependencies = null;
    }

    String filePattern = json[ConfigKeys.filePatternEagleItemKey];

    return EagleEyeConfigItem(
      dependenciesAllowed: dependenciesAllowed,
      forbiddenDependencies: forbiddenDependencies,
      exclusiveDependencies: exclusiveDependencies,
      filePattern: filePattern,
    );
  }
}
