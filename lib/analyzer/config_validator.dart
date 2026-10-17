import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/exceptions/invalid_config_exception.dart';
import 'package:eagle_eye/util/check_reporter.dart';

/// Validates an [EagleEyeConfig] before the analysis starts.
///
/// The validator performs two phases:
/// 1. Structural validation: every rule must have a non-empty, valid
///    `filePattern`, every dependency pattern must compile, and each rule
///    must define at most one constraint.
/// 2. Conflict detection: a file in `lib/` must not match more than one rule.
///
/// Any problem is reported through an [InvalidConfigException], which causes
/// the CLI to exit before inspecting imports.
class EagleEyeConfigValidator {
  /// Helper class used to perform regex-based pattern matching.
  final RegexHelper regexHelper;

  /// Optional callback used to report the validation step.
  final CheckReporter? onCheck;

  /// Creates a new [EagleEyeConfigValidator] with the given [regexHelper] and
  /// optional [onCheck] reporter.
  EagleEyeConfigValidator({required this.regexHelper, this.onCheck});

  /// Validates [config] against the given [filePaths].
  ///
  /// Throws an [InvalidConfigException] when the configuration is structurally
  /// invalid or when a file matches more than one rule.
  void validate({
    required EagleEyeConfig config,
    required Iterable<String> filePaths,
  }) {
    final structureProblems = _validateStructure(config);
    if (structureProblems.isNotEmpty) {
      throw InvalidConfigException(structureProblems.join('\n'));
    }

    final files = filePaths.toList();
    onCheck?.call(
      'Validating ${config.items.length} rule(s) against '
      '${files.length} file(s)',
    );

    final conflicts = _findConflicts(config, files);
    if (conflicts.isNotEmpty) {
      throw InvalidConfigException(_conflictMessage(config, conflicts));
    }
  }

  List<String> _validateStructure(EagleEyeConfig config) {
    final problems = <String>[];

    for (var index = 0; index < config.items.length; index++) {
      final item = config.items[index];
      final label = _ruleLabel(index, item);

      _validateFilePattern(problems, label, item.filePattern);
      _validateDependencies(
        problems,
        label,
        'forbiddenDependencies',
        item.forbiddenDependencies,
      );
      _validateDependencies(
        problems,
        label,
        'exclusiveDependencies',
        item.exclusiveDependencies,
      );
      _validateConstraints(problems, label, item);
    }

    return problems;
  }

  void _validateFilePattern(
    List<String> problems,
    String label,
    String pattern,
  ) {
    if (pattern.trim().isEmpty) {
      problems.add('$label has an empty "filePattern".');
    } else if (!_isValidPattern(pattern)) {
      problems.add('$label has an invalid "filePattern": "$pattern".');
    }
  }

  void _validateDependencies(
    List<String> problems,
    String label,
    String key,
    List<String>? patterns,
  ) {
    if (patterns == null) {
      return;
    }
    for (final pattern in patterns) {
      if (!_isValidPattern(pattern)) {
        problems.add('$label has an invalid $key pattern: "$pattern".');
      }
    }
  }

  void _validateConstraints(
    List<String> problems,
    String label,
    EagleEyeConfigItem item,
  ) {
    final constraints = <String>[];
    if (item.dependenciesAllowed == false) {
      constraints.add('dependenciesAllowed: false');
    }
    if (item.forbiddenDependencies?.isNotEmpty ?? false) {
      constraints.add('forbiddenDependencies');
    }
    if (item.exclusiveDependencies?.isNotEmpty ?? false) {
      constraints.add('exclusiveDependencies');
    }

    if (constraints.length > 1) {
      problems.add(
        '$label defines more than one constraint: '
        '${constraints.join(', ')}. Use only one of dependenciesAllowed: '
        'false, forbiddenDependencies, or exclusiveDependencies.',
      );
    }
  }

  Map<String, List<int>> _findConflicts(
    EagleEyeConfig config,
    List<String> files,
  ) {
    final conflicts = <String, List<int>>{};

    for (final filePath in files) {
      final matchedIndexes = <int>[];
      for (var index = 0; index < config.items.length; index++) {
        final item = config.items[index];
        if (regexHelper.matchesPattern(filePath, item.filePattern)) {
          matchedIndexes.add(index);
        }
      }
      if (matchedIndexes.length > 1) {
        conflicts[filePath] = matchedIndexes;
      }
    }

    return conflicts;
  }

  String _conflictMessage(
    EagleEyeConfig config,
    Map<String, List<int>> conflicts,
  ) {
    final buffer = StringBuffer(
      'Each file must match exactly one rule, but the following files match '
      'more than one:\n',
    );
    final files = conflicts.keys.toList()..sort();

    for (final filePath in files) {
      buffer.writeln('\n$filePath');
      for (final index in conflicts[filePath]!) {
        final item = config.items[index];
        buffer.writeln('  • ${_ruleLabel(index, item)}: ${item.filePattern}');
      }
    }

    buffer.write(
      '\nUpdate the "filePattern" values so each file matches only one rule.',
    );
    return buffer.toString();
  }

  String _ruleLabel(int index, EagleEyeConfigItem item) {
    final name = item.name;
    if (name == null || name.isEmpty) {
      return 'Rule #${index + 1}';
    }
    return 'Rule #${index + 1} ("$name")';
  }

  bool _isValidPattern(String pattern) {
    try {
      RegExp(pattern.replaceAll('*', '.*'));
      return true;
    } on FormatException {
      return false;
    }
  }
}
