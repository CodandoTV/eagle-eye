import 'package:eagle_eye/constants.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';

class JsonMapper {
  EagleEyeConfigItem map(Map<String, dynamic> json) {
    bool? noDependsEnabled = json[Constants.noDependsEnabledEagleItemKey];

    List<String>? noDepsWithPatterns;
    try {
      noDepsWithPatterns =
          json[Constants.noDepsWithPatternsEagleItemKey] as List<String>;
    } catch (e) {
      noDepsWithPatterns = null;
    }

    List<String>? justDepsWithPatterns;
    try {
      justDepsWithPatterns = _convertList(
        json[Constants.justDepsWithPatternsEagleItemKey] as List<dynamic>,
      );
    } catch (e) {
      justDepsWithPatterns = null;
    }

    String filePattern = json[Constants.filePatternEagleItemKey];

    return EagleEyeConfigItem(
      noDependsEnabled: noDependsEnabled,
      noDepsWithPatterns: noDepsWithPatterns,
      justDepsWithPatterns: justDepsWithPatterns,
      filePattern: filePattern,
    );
  }

  List<String> _convertList(List<dynamic> list) {
    return List<String>.from(list);
  }
}
