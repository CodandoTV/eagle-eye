/// Represents a single rule item in the Eagle Eye configuration file.
///
/// Each [EagleEyeConfigItem] defines dependency constraints for files
/// that match a specific [filePattern].
/// These constraints control which imports are allowed or forbidden
/// within that scope.
///
/// Configuration behavior:
/// - If [dependenciesAllowed] is `false`, the file cannot import anything.
/// - If [forbiddenDependencies] is provided, the file **cannot** import
///   any module matching those patterns.
/// - If [exclusiveDependencies] is provided, the file **can only** import
///   modules that match those patterns.
class EagleEyeConfigItem {
  /// If `false`, the file should not contain any import statements.
  bool? dependenciesAllowed = true;

  /// List of regex or wildcard patterns representing forbidden imports.
  List<String>? forbiddenDependencies;

  /// List of regex or wildcard patterns representing allowed imports.
  List<String>? exclusiveDependencies;

  /// Pattern used to identify which files this rule applies to.
  String filePattern;

  /// Optional human-readable name for this rule.
  String? name;

  /// Creates a new [EagleEyeConfigItem] instance with the given parameters.
  EagleEyeConfigItem({
    this.dependenciesAllowed,
    this.forbiddenDependencies,
    this.exclusiveDependencies,
    required this.filePattern,
    this.name,
  });
}
