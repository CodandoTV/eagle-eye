import 'dart:convert';

import 'package:eagle_eye/model/config_keys.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/exceptions/invalid_config_exception.dart';
import 'package:eagle_eye/model/exceptions/invalid_json_key_exception.dart';

/// A utility class that converts JSON configuration data
/// into [EagleEyeConfig] and [EagleEyeConfigItem] objects.
///
/// The [JsonConverter] is responsible for parsing the `eagle_eye_config.json`
/// file and safely mapping its contents into structured models used by
/// the Eagle Eye rule enforcement system.
///
/// It supports the following keys:
/// - `dependenciesAllowed` — disables all imports when `false`
/// - `forbiddenDependencies` — defines forbidden dependency patterns
/// - `exclusiveDependencies` — defines allowed dependency patterns
/// - `filePattern` — defines which files the rule applies to
/// - `name` — optional human-readable rule name
class JsonConverter {
  void _checkKeys(List<String> keys) {
    final validKeys = [
      ConfigKeys.filePatternEagleItemKey,
      ConfigKeys.dependenciesAllowedEagleItemKey,
      ConfigKeys.exclusiveDependenciesEagleItemKey,
      ConfigKeys.forbiddenDependenciesEagleItemKey,
      ConfigKeys.nameEagleItemKey,
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
  /// Throws an [InvalidConfigException] when the JSON is malformed, when the
  /// top-level value is not an array, or when a rule cannot be parsed.
  EagleEyeConfig convert(String jsonText) {
    late final dynamic jsonData;
    try {
      jsonData = jsonDecode(jsonText);
    } on FormatException catch (e) {
      throw InvalidConfigException(
        'The configuration file is not valid JSON: ${e.message}',
      );
    }

    if (jsonData is! List) {
      throw InvalidConfigException(
        'The configuration file must contain a JSON array of rules.',
      );
    }

    List<EagleEyeConfigItem> eagleConfigItems = [];
    for (var index = 0; index < jsonData.length; index++) {
      final dynamic jsonDataItem = jsonData[index];
      if (jsonDataItem is! Map<String, dynamic>) {
        throw InvalidConfigException(
          'Rule #${index + 1} must be a JSON object.',
        );
      }

      _checkKeys(jsonDataItem.keys.toList());

      try {
        EagleEyeConfigItem configItem = EagleEyeConfigItem.fromJson(
          jsonDataItem,
        );
        eagleConfigItems.add(configItem);
      } on InvalidConfigException catch (e) {
        throw InvalidConfigException('Rule #${index + 1}: ${e.details}');
      }
    }
    return EagleEyeConfig(items: eagleConfigItems);
  }
}
