import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/error_info.dart';

class EagleEyeVisitor extends RecursiveAstVisitor<void> {
  final EagleEyeConfigItem configItem;
  final String filePath;
  final Function(ErrorInfo) errorCallback;

  EagleEyeVisitor({
    required this.configItem,
    required this.filePath,
    required this.errorCallback,
  });

  @override
  void visitImportDirective(ImportDirective node) {
    if (configItem.noDependsEnabled == true) {
      errorCallback(
        ErrorInfo(
          filePath: filePath,
          errorMessage: '$filePath should not contains any import.',
        ),
      );
    }

    // TODO: Implement other rules based on eagle item
    super.visitImportDirective(node);
  }
}
