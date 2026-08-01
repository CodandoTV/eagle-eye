/// Identifies the type of architectural rule that was violated.
enum RuleType {
  /// The file must contain no imports at all.
  noImportsAllowed,

  /// The file imported a dependency that is forbidden.
  forbiddenDependency,

  /// The file imported a dependency outside the exclusive allowlist.
  exclusiveDependency,
}

/// Represents a single architecture violation detected during analysis.
class Violation {
  /// Which rule type was violated.
  final RuleType ruleType;

  /// Path of the file containing the violation.
  final String filePath;

  /// Line number (1-based) where the violation occurred.
  final int lineNumber;

  /// Column number (1-based) where the violation occurred.
  final int columnNumber;

  /// The import URI that triggered the violation, if applicable.
  final String? importUri;

  /// Optional human-readable name from the config rule.
  final String? ruleName;

  /// Human-readable description of the violation.
  final String description;

  /// Creates a new [Violation] with the given properties.
  const Violation({
    required this.ruleType,
    required this.filePath,
    required this.lineNumber,
    required this.columnNumber,
    this.importUri,
    this.ruleName,
    required this.description,
  });
}
