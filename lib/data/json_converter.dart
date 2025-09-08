import 'dart:convert';

import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';

class JsonConverter {
  static const noDependsEnabledEagleItemKey = 'noDependsEnabled';
  static const noDepsWithPatternsEagleItemKey = 'noDepsWithPatterns';
  static const filePatternEagleItemKey = 'filePattern';

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

  EagleEyeConfigItem _map(Map<String, dynamic> json) {
    bool? noDependsEnabled = json[noDependsEnabledEagleItemKey];

    List<String>? noDepsWithPatterns;
    try {
      noDepsWithPatterns = _convertList(
        json[noDepsWithPatternsEagleItemKey] as List<dynamic>,
      );
    } catch (e) {
      noDepsWithPatterns = null;
    }

    String filePattern = json[filePatternEagleItemKey];

    return EagleEyeConfigItem(
      noDependsEnabled: noDependsEnabled,
      noDepsWithPatterns: noDepsWithPatterns,
      filePattern: filePattern,
    );
  }

  List<String> _convertList(List<dynamic> list) {
    return List<String>.from(list);
  }
}
