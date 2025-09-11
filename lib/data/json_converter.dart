import 'dart:convert';

import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';

class JsonConverter {
  static const noDependsEnabledEagleItemKey = 'noDependsEnabled';
  static const doNotWithPatternsEagleItemKey = 'doNotWithPatterns';
  static const justWithPatternsEagleItemKey = 'justWithPatterns';
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

  List<String> _convertList(List<dynamic> list) {
    return List<String>.from(list);
  }
}
