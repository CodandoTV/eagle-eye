import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:eagle_eye/logger_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';

class NoDependencyRuleVisitor extends RecursiveAstVisitor<void> {
  final EagleEyeConfig config;
  final String filePath;
  NoDependencyRuleVisitor(this.config, this.filePath);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri != null) {
      LoggerHelper.printError('$filePath should not contains any import.');
      exit(1);
    }
    super.visitImportDirective(node);
  }
}
