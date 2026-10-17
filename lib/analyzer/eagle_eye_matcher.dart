import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/util/check_reporter.dart';

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

  /// Optional callback used to report each file pattern checked.
  final CheckReporter? onCheck;

  /// Creates a new [EagleEyeMatcher] instance with the provided [config],
  /// [regexHelper], and optional [onCheck] reporter.
  EagleEyeMatcher({
    required this.config,
    required this.regexHelper,
    this.onCheck,
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
      onCheck?.call(
        '  filePattern "${configurationItem.filePattern}" vs "$filePath": '
        '${configItemFounded ? 'match' : 'no match'}',
      );
      if (configItemFounded) {
        final ruleLabel =
            configurationItem.name ?? configurationItem.filePattern;
        onCheck?.call('  rule "$ruleLabel" selected');
        return configurationItem;
      }
    }
    return null;
  }
}
