import 'dart:convert';

import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';

/// A utility class that converts JSON configuration data
/// into [EagleEyeConfig] and [EagleEyeConfigItem] objects.
///
/// The [JsonConverter] is responsible for parsing the `eagle_eye_config.json`
/// file and safely mapping its contents into structured models used by
/// the Eagle Eye rule enforcement system.
///
/// It supports the following keys:
/// - `noDependsEnabled` — disables all imports when `true`
/// - `doNotWithPatterns` — defines forbidden dependency patterns
/// - `justWithPatterns` — defines allowed dependency patterns
/// - `filePattern` — defines which files the rule applies to
class JsonConverter {
  /// JSON key for enabling or disabling all dependencies in a rule item.
  static const noDependsEnabledEagleItemKey = 'noDependsEnabled';

  /// JSON key for the list of forbidden dependency patterns.
  static const doNotWithPatternsEagleItemKey = 'doNotWithPatterns';

  /// JSON key for the list of allowed dependency patterns.
  static const justWithPatternsEagleItemKey = 'justWithPatterns';

  /// JSON key for the file-matching pattern.
  static const filePatternEagleItemKey = 'filePattern';

  /// Converts a JSON string ([jsonText]) into an [EagleEyeConfig] object.
  ///
  /// The JSON is expected to be an array of configuration items.
  /// Invalid entries are skipped if they cannot be parsed.
  EagleEyeConfig convert(String jsonText) {
    List<dynamic> jsonData = jsonDecode(jsonText);

    List<EagleEyeConfigItem> eagleConfigItems = [];
    for (var jsonItem in jsonData) {
      EagleEyeConfigItem configItem = _map(
        jsonItem as Map<String, dynamic>,
      );
      eagleConfigItems.add(configItem);
    }

    return EagleEyeConfig(items: eagleConfigItems);
  }

  /// Maps a single JSON object into an [EagleEyeConfigItem].
  ///
  /// Handles missing or invalid fields gracefully by assigning `null`
  /// where appropriate.
  EagleEyeConfigItem _map(Map<String, dynamic> json) {
    bool? noDependsEnabled = json[noDependsEnabledEagleItemKey];

    List<String>? doNotWithPatterns;
    try {
      doNotWithPatterns = _convertList(
        json[doNotWithPatternsEagleItemKey] as List<dynamic>,
      );
    } catch (e) {
      doNotWithPatterns = null;
    }

    List<String>? justWithPatterns;
    try {
      justWithPatterns = _convertList(
        json[justWithPatternsEagleItemKey] as List<dynamic>,
      );
    } catch (e) {
      justWithPatterns = null;
    }

    String filePattern = json[filePatternEagleItemKey];

    return EagleEyeConfigItem(
      noDependsEnabled: noDependsEnabled,
      doNotWithPatterns: doNotWithPatterns,
      justWithPatterns: justWithPatterns,
      filePattern: filePattern,
    );
  }

  /// Converts a list of dynamic JSON values into a list of strings.
  List<String> _convertList(List<dynamic> list) {
    return List<String>.from(list);
  }
}
