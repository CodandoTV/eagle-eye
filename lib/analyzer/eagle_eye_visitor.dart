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

  EagleEyeVisitor({
    required this.configItem,
    required this.filePath,
    required this.errorCallback,
    required this.regexHelper,
  });

  @override
  void visitImportDirective(ImportDirective node) {
    super.visitImportDirective(node);

    if (configItem.noDependsEnabled == true) {
      errorCallback(
        ErrorInfo(
          filePath: filePath,
          errorMessage: '$filePath should not contains any import.',
        ),
      );
    } else if (configItem.noDepsWithPatterns != null) {
      final importDirective = node.uri.stringValue;

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
