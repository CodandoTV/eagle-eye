import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:eagle_eye/analyzer/checker/exclusive_dependencies_rule_checker.dart';
import 'package:eagle_eye/analyzer/checker/forbidden_dependencies_rule_checker.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/violation.dart';
import 'package:eagle_eye/util/check_reporter.dart';

/// A visitor that analyzes import directives to validate architectural rules
/// defined in an [EagleEyeConfigItem].
///
/// The [EagleEyeVisitor] traverses the Dart AST and checks each import
/// directive to ensure it follows the dependency rules specified in
/// [configItem]. It only validates **internal imports** belonging to
/// the same application (filtered using [applicationName]).
///
/// Depending on the configuration, it can:
/// - Forbid any imports (`noDependsEnabled`)
/// - Disallow specific imports (`doNotWithPatterns`)
/// - Restrict imports to specific modules only (`justWithPatterns`)
///
/// Violations are reported via the [errorCallback].
class EagleEyeVisitor extends RecursiveAstVisitor<void> {
  /// The configuration item that defines the dependency rules to enforce.
  final EagleEyeConfigItem configItem;

  /// The path of the file currently being analyzed.
  final String filePath;

  /// Callback used to report detected rule violations.
  final Function(Violation) errorCallback;

  /// Helper used for regex-based pattern matching.
  final RegexHelper regexHelper;

  /// The name of the current application, used to identify internal imports.
  final String applicationName;

  /// The parsed compilation unit, used to resolve line/column numbers.
  final CompilationUnit unit;

  /// Optional callback used to report each import and pattern checked.
  final CheckReporter? onCheck;

  /// Creates a new [EagleEyeVisitor] with the given configuration,
  /// file path, callback, helpers, and optional [onCheck] reporter.
  EagleEyeVisitor({
    required this.configItem,
    required this.filePath,
    required this.errorCallback,
    required this.regexHelper,
    required this.applicationName,
    required this.unit,
    this.onCheck,
  });

  @override
  void visitImportDirective(ImportDirective node) {
    super.visitImportDirective(node);

    final importDirective = node.uri.stringValue;
    final location = unit.lineInfo.getLocation(node.offset);
    final lineNumber = location.lineNumber;
    final columnNumber = location.columnNumber;

    if (importDirective == null) {
      onCheck?.call('  skipping import without URI (line $lineNumber)');
      return;
    }

    if (!importDirective.contains(applicationName)) {
      onCheck?.call(
        '  skipping external import "$importDirective" (line $lineNumber)',
      );
      return;
    }

    onCheck?.call(
      '  internal import "$importDirective" (line $lineNumber)',
    );

    if (configItem.dependenciesAllowed == false) {
      onCheck?.call('    dependenciesAllowed is false -> violation');
      errorCallback(
        Violation(
          ruleType: RuleType.noImportsAllowed,
          filePath: filePath,
          lineNumber: lineNumber,
          columnNumber: columnNumber,
          importUri: importDirective,
          ruleName: configItem.name,
          description: '$filePath should not contains any import.',
        ),
      );
    } else if (configItem.forbiddenDependencies != null) {
      onCheck?.call('    rule type: forbiddenDependencies');
      final checker = ForbiddenDependenciesRuleChecker(
        regexHelper,
        onCheck: onCheck,
      );
      String? errorDescription = checker.check(
        noDepsWithPatterns: configItem.forbiddenDependencies!,
        importDirective: importDirective,
        filePath: filePath,
      );

      if (errorDescription != null) {
        errorCallback(
          Violation(
            ruleType: RuleType.forbiddenDependency,
            filePath: filePath,
            lineNumber: lineNumber,
            columnNumber: columnNumber,
            importUri: importDirective,
            ruleName: configItem.name,
            description: errorDescription,
          ),
        );
      }
    } else if (configItem.exclusiveDependencies != null) {
      onCheck?.call('    rule type: exclusiveDependencies');
      final checker = ExclusiveDependenciesRuleChecker(
        regexHelper,
        onCheck: onCheck,
      );
      String? errorDescription = checker.check(
        justWithPatterns: configItem.exclusiveDependencies!,
        importDirective: importDirective,
        filePath: filePath,
      );

      if (errorDescription != null) {
        errorCallback(
          Violation(
            ruleType: RuleType.exclusiveDependency,
            filePath: filePath,
            lineNumber: lineNumber,
            columnNumber: columnNumber,
            importUri: importDirective,
            ruleName: configItem.name,
            description: errorDescription,
          ),
        );
      }
    } else {
      onCheck?.call('    no dependency constraint configured -> allowed');
    }
  }
}
