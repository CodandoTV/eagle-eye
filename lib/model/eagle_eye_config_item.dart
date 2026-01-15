import 'package:eagle_eye/model/config_keys.dart';

/// Represents a single rule item in the Eagle Eye configuration file.
///
/// Each [EagleEyeConfigItem] defines dependency constraints for files
/// that match a specific [filePattern].
/// These constraints control which imports are allowed or forbidden
/// within that scope.
///
/// Configuration behavior:
/// - If [noDependsEnabled] is `true`, the file cannot import anything.
/// - If [doNotWithPatterns] is provided, the file **cannot** import
///   any module matching those patterns.
/// - If [justWithPatterns] is provided, the file **can only** import
///   modules that match those patterns.
class EagleEyeConfigItem {
  /// If `true`, the file should not contain any import statements.
  bool? noDependsEnabled = false;

  /// List of regex or wildcard patterns representing forbidden imports.
  List<String>? doNotWithPatterns;

  /// List of regex or wildcard patterns representing allowed imports.
  List<String>? justWithPatterns;

  /// Pattern used to identify which files this rule applies to.
  String filePattern;

  /// Creates a new [EagleEyeConfigItem] instance with the given parameters.
  EagleEyeConfigItem({
    this.noDependsEnabled,
    this.doNotWithPatterns,
    this.justWithPatterns,
    required this.filePattern,
  });

  /// Maps a single JSON object into an [EagleEyeConfigItem].
  ///
  /// Handles missing or invalid fields gracefully by assigning `null`
  /// where appropriate.
  factory EagleEyeConfigItem.fromJson(Map<String, dynamic> json) {
    bool? noDependsEnabled = json[ConfigKeys.noDependsEnabledEagleItemKey];

    List<String>? doNotWithPatterns;
    try {
      doNotWithPatterns = List<String>.from(
        json[ConfigKeys.doNotWithPatternsEagleItemKey] as List<dynamic>,
      );
    } catch (e) {
      doNotWithPatterns = null;
    }

    List<String>? justWithPatterns;
    try {
      justWithPatterns = List<String>.from(
        json[ConfigKeys.justWithPatternsEagleItemKey] as List<dynamic>,
      );
    } catch (e) {
      justWithPatterns = null;
    }

    String filePattern = json[ConfigKeys.filePatternEagleItemKey];

    return EagleEyeConfigItem(
      noDependsEnabled: noDependsEnabled,
      doNotWithPatterns: doNotWithPatterns,
      justWithPatterns: justWithPatterns,
      filePattern: filePattern,
    );
  }
}
