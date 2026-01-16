/// Define the configuration keys used by the developer when the configuration
/// file is created.
class ConfigKeys {
  /// JSON key for enabling or disabling all dependencies in a rule item.
  static const dependenciesAllowedEagleItemKey = 'dependenciesAllowed';

  /// JSON key for the list of forbidden dependency patterns.
  static const forbiddenDependenciesEagleItemKey = 'forbiddenDependencies';

  /// JSON key for the list of allowed dependency patterns.
  static const exclusiveDependenciesEagleItemKey = 'exclusiveDependencies';

  /// JSON key for the file-matching pattern.
  static const filePatternEagleItemKey = 'filePattern';
}
