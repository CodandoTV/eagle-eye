import 'dart:convert';

import 'package:eagle_eye/model/config_keys.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/exceptions/invalid_json_key_exception.dart';

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
  void _checkKeys(List<String> keys) {
    final validKeys = [
      ConfigKeys.filePatternEagleItemKey,
      ConfigKeys.dependenciesAllowedEagleItemKey,
      ConfigKeys.exclusiveDependenciesEagleItemKey,
      ConfigKeys.forbiddenDependenciesEagleItemKey,
    ];
    for (var key in keys.toList()) {
      if (validKeys.contains(key) == false) {
        throw InvalidJsonKeyException();
      }
    }
  }

  /// Converts a JSON string ([jsonText]) into an [EagleEyeConfig] object.
  ///
  /// The JSON is expected to be an array of configuration items.
  /// Invalid entries are skipped if they cannot be parsed.
  EagleEyeConfig convert(String jsonText) {
    List<dynamic> jsonData = jsonDecode(jsonText);

    List<EagleEyeConfigItem> eagleConfigItems = [];
    for (var jsonDataItem in jsonData) {
      final jsonItem = jsonDataItem as Map<String, dynamic>;

      _checkKeys(jsonItem.keys.toList());

      EagleEyeConfigItem configItem = EagleEyeConfigItem.fromJson(
        jsonItem,
      );
      eagleConfigItems.add(configItem);
    }
    return EagleEyeConfig(items: eagleConfigItems);
  }
}
