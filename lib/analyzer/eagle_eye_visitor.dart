import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:eagle_eye/analyzer/checker/exclusive_dependencies_rule_checker.dart';
import 'package:eagle_eye/analyzer/checker/forbidden_dependencies_rule_checker.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/violation.dart';

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

  /// Creates a new [EagleEyeVisitor] with the given configuration,
  /// file path, callback, and helpers.
  EagleEyeVisitor({
    required this.configItem,
    required this.filePath,
    required this.errorCallback,
    required this.regexHelper,
    required this.applicationName,
    required this.unit,
  });

  @override
  void visitImportDirective(ImportDirective node) {
    super.visitImportDirective(node);

    final importDirective = node.uri.stringValue;

    if (importDirective?.contains(applicationName) == true) {
      final location = unit.lineInfo.getLocation(node.offset);
      final lineNumber = location.lineNumber;
      final columnNumber = location.columnNumber;

      if (configItem.dependenciesAllowed == false) {
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
        if (importDirective != null) {
          final checker = ForbiddenDependenciesRuleChecker(regexHelper);
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
        }
      } else if (configItem.exclusiveDependencies != null) {
        if (importDirective != null) {
          final checker = ExclusiveDependenciesRuleChecker(regexHelper);
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
        }
      }
    }
  }
}
