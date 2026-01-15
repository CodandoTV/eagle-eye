/// Define the configuration keys used by the developer when the configuration
/// file is created.
class ConfigKeys {
  /// JSON key for enabling or disabling all dependencies in a rule item.
  static const noDependsEnabledEagleItemKey = 'noDependsEnabled';

  /// JSON key for the list of forbidden dependency patterns.
  static const doNotWithPatternsEagleItemKey = 'doNotWithPatterns';

  /// JSON key for the list of allowed dependency patterns.
  static const justWithPatternsEagleItemKey = 'justWithPatterns';

  /// JSON key for the file-matching pattern.
  static const filePatternEagleItemKey = 'filePattern';
}
