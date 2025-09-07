import 'package:eagle_eye/constants.dart';

class EagleEyeConfigItem {
  bool? noDependsEnabled = false;
  List<String>? noDepsWithPatterns;
  List<String>? justDepsWithPatterns;
  String filePattern;

  EagleEyeConfigItem({
    this.noDependsEnabled,
    this.noDepsWithPatterns,
    this.justDepsWithPatterns,
    required this.filePattern,
  });

  factory EagleEyeConfigItem.fromJson(Map<String, dynamic> json) {
    return EagleEyeConfigItem(
      noDependsEnabled: json[Constants.noDependsEnabledEagleItemKey],
      noDepsWithPatterns: json[Constants.noDepsWithPatternsEagleItemKey],
      justDepsWithPatterns: json[Constants.justDepsWithPatternsEagleItemKey],
      filePattern: json[Constants.filePatternEagleItemKey],
    );
  }
}
