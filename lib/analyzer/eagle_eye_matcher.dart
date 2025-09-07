import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';

class EagleEyeMatcher {
  final EagleEyeConfig config;
  final RegexHelper regexHelper;

  EagleEyeMatcher({
    required this.config,
    required this.regexHelper,
  });

  EagleEyeConfigItem? find(filePath) {
    for (var configurationItem in config.items) {
      bool configItemFounded = regexHelper.matchesPattern(
        filePath,
        configurationItem.filePattern,
      );
      if (configItemFounded) {
        return configurationItem;
      }
    }
    return null;
  }
}
