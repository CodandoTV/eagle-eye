import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Loads Dart source files from disk and parses them into ASTs.
///
/// This is a data-layer concern: it owns reading source files and turning
/// them into [CompilationUnit] values for the analyzer.
class DartSourceLoader {
  /// Parses the Dart file at [path] into a [CompilationUnit].
  CompilationUnit load(String path) {
    return parseFile(
      path: path,
      featureSet: FeatureSet.latestLanguageVersion(),
    ).unit;
  }
}
