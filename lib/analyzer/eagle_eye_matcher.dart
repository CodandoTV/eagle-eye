import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';

/// A matcher finds the configuration item that applies to a given file path.
///
/// The [EagleEyeMatcher] scans through all [EagleEyeConfigItem]s defined
/// in the provided [EagleEyeConfig] and returns the first one whose
/// [filePattern] matches the given file path. It uses [RegexHelper]
/// for regex-based matching.
class EagleEyeMatcher {
  /// The configuration containing all available rule items.
  final EagleEyeConfig config;

  /// Helper class used to perform regex-based pattern matching.
  final RegexHelper regexHelper;

  /// Creates a new [EagleEyeMatcher] instance with the provided [config]
  /// and [regexHelper].
  EagleEyeMatcher({
    required this.config,
    required this.regexHelper,
  });

  /// Finds the first [EagleEyeConfigItem] whose [filePattern]
  /// matches the given [filePath].
  ///
  /// - [filePath]: The path of the file to check.
  ///
  /// Returns the matching [EagleEyeConfigItem] if found,
  /// or `null` if no configuration item matches.
  EagleEyeConfigItem? find(String filePath) {
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
