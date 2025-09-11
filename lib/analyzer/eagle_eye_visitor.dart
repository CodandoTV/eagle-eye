import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:eagle_eye/analyzer/checker/do_not_with_rule_checker.dart';
import 'package:eagle_eye/analyzer/checker/just_with_rule_checker.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/error_info.dart';

class EagleEyeVisitor extends RecursiveAstVisitor<void> {
  final EagleEyeConfigItem configItem;
  final String filePath;
  final Function(ErrorInfo) errorCallback;
  final RegexHelper regexHelper;
  final String applicationName;

  EagleEyeVisitor({
    required this.configItem,
    required this.filePath,
    required this.errorCallback,
    required this.regexHelper,
    required this.applicationName,
  });

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
