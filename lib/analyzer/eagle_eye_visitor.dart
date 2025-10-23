import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:eagle_eye/analyzer/checker/do_not_with_rule_checker.dart';
import 'package:eagle_eye/analyzer/checker/just_with_rule_checker.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/error_info.dart';

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
  final Function(ErrorInfo) errorCallback;

  /// Helper used for regex-based pattern matching.
  final RegexHelper regexHelper;

  /// The name of the current application, used to identify internal imports.
  final String applicationName;

  /// Creates a new [EagleEyeVisitor] with the given configuration,
  /// file path, callback, and helpers.
  EagleEyeVisitor({
    required this.configItem,
    required this.filePath,
    required this.errorCallback,
    required this.regexHelper,
    required this.applicationName,
  });

  /// Visits each [ImportDirective] node in the AST and checks if the import
  /// complies with the dependency rules defined in [configItem].
  ///
  /// - Ignores third-party imports (not containing [applicationName]).
  /// - Reports violations using [errorCallback].
  @override
  void visitImportDirective(ImportDirective node) {
    super.visitImportDirective(node);

    final importDirective = node.uri.stringValue;

    // Only check internal software components of the app
    // (discard any third party libraries)
    if (importDirective?.contains(applicationName) == true) {
      // Check rules exclusively
      if (configItem.noDependsEnabled == true) {
        errorCallback(
          ErrorInfo(
            filePath: filePath,
            errorMessage: '$filePath should not contains any import.',
          ),
        );
      } else if (configItem.doNotWithPatterns != null) {
        if (importDirective != null) {
          ErrorInfo? errorInfo = DoNotWithRuleChecker(regexHelper).check(
            noDepsWithPatterns: configItem.doNotWithPatterns!,
            importDirective: importDirective,
            filePath: filePath,
          );

          if (errorInfo != null) {
            errorCallback(errorInfo);
          }
        }
      } else if (configItem.justWithPatterns != null) {
        if (importDirective != null) {
          ErrorInfo? errorInfo = JustWithRuleChecker(regexHelper).check(
            justWithPatterns: configItem.justWithPatterns!,
            importDirective: importDirective,
            filePath: filePath,
          );

          if (errorInfo != null) {
            errorCallback(errorInfo);
          }
        }
      }
    }
  }
}
