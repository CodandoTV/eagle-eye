import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';

class EagleEyeMatcher {
  EagleEyeConfig config;

  EagleEyeMatcher(this.config);

  EagleEyeConfigItem? find(filePath) {
    for (var configurationItem in config.items) {
      bool configItemFounded = _matchesPattern(
        filePath,
        configurationItem.filePattern,
      );
      if (configItemFounded) {
        return configurationItem;
      }
    }
    return null;
  }

  bool _matchesPattern(String text, String pattern) {
    final regex = RegExp(pattern.replaceAll('*', '.*'));
    return regex.hasMatch(text);
  }
}
