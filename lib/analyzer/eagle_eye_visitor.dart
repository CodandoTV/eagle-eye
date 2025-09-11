import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
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
      if (configItem.noDependsEnabled == true) {
        errorCallback(
          ErrorInfo(
            filePath: filePath,
            errorMessage: '$filePath should not contains any import.',
          ),
        );
      } else if (configItem.noDepsWithPatterns != null) {
        if (importDirective != null) {
          for (var noDepsWithItem in configItem.noDepsWithPatterns!) {
            var matches = regexHelper.matchesPattern(
              importDirective,
              noDepsWithItem,
            );
            if (matches == true) {
              errorCallback(
                ErrorInfo(
                  filePath: filePath,
                  errorMessage:
                      '$filePath should not depends on $importDirective',
                ),
              );
            }
          }
        }
      }
    }
  }
}
