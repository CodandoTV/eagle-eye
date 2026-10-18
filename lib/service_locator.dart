import 'package:analyzer/dart/ast/ast.dart';
import 'package:eagle_eye/analyzer/config_validator.dart';
import 'package:eagle_eye/analyzer/eagle_eye_matcher.dart';
import 'package:eagle_eye/analyzer/eagle_eye_visitor.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/data/dart_source_loader.dart';
import 'package:eagle_eye/data/eagle_eye_repository.dart';
import 'package:eagle_eye/data/file_helper.dart';
import 'package:eagle_eye/data/json_converter.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/violation.dart';
import 'package:eagle_eye/util/check_reporter.dart';
import 'package:eagle_eye/util/cli_options.dart';
import 'package:eagle_eye/util/output_renderer.dart';

/// Creates and wires every dependency used by Eagle Eye.
///
/// The [ServiceLocator] is the composition root of the application. It owns
/// the shared helpers and exposes factory methods for the objects that are
/// created per configuration or per analyzed file.
class ServiceLocator {
  /// Creates a new [ServiceLocator] with all shared dependencies wired.
  ServiceLocator();

  final FileHelper _fileHelper = FileHelper();
  final JsonConverter _jsonConverter = JsonConverter();
  final RegexHelper _regexHelper = RegexHelper();
  final OutputRenderer _outputRenderer = OutputRenderer();
  final DartSourceLoader _dartSourceLoader = DartSourceLoader();

  late final EagleEyeRepository _repository = EagleEyeRepositoryImpl(
    fileHelper: _fileHelper,
    jsonConverter: _jsonConverter,
  );

  /// The repository used to load the configuration and project files.
  EagleEyeRepository get repository => _repository;

  /// The helper used for regex-based pattern matching.
  RegexHelper get regexHelper => _regexHelper;

  /// The renderer used to format detected violations.
  OutputRenderer get outputRenderer => _outputRenderer;

  /// The loader used to read and parse Dart source files.
  DartSourceLoader get dartSourceLoader => _dartSourceLoader;

  /// Parses the command-line [args] into [CliOptions].
  CliOptions parseCliOptions(List<String> args) => CliOptions.parse(args);

  /// Creates a configuration validator.
  EagleEyeConfigValidator createConfigValidator({CheckReporter? onCheck}) {
    return EagleEyeConfigValidator(regexHelper: _regexHelper, onCheck: onCheck);
  }

  /// Creates a matcher for the given [config].
  EagleEyeMatcher createMatcher({
    required EagleEyeConfig config,
    CheckReporter? onCheck,
  }) {
    return EagleEyeMatcher(
      config: config,
      regexHelper: _regexHelper,
      onCheck: onCheck,
    );
  }

  /// Creates a visitor that analyzes imports found in [unit].
  EagleEyeVisitor createVisitor({
    required EagleEyeConfigItem configItem,
    required String filePath,
    required String applicationName,
    required CompilationUnit unit,
    required void Function(Violation) errorCallback,
    CheckReporter? onCheck,
  }) {
    return EagleEyeVisitor(
      configItem: configItem,
      filePath: filePath,
      errorCallback: errorCallback,
      regexHelper: _regexHelper,
      applicationName: applicationName,
      unit: unit,
      onCheck: onCheck,
    );
  }
}
