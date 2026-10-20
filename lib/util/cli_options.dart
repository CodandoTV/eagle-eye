import 'package:args/args.dart';

/// Parsed command-line options accepted by Eagle Eye.
class CliOptions {
  /// Whether verbose check tracing is enabled.
  final bool verbose;

  /// Whether the user requested the usage information.
  final bool showHelp;

  /// The file paths to analyze.
  ///
  /// An empty list means every Dart file under `lib/` should be analyzed.
  final List<String> files;

  /// The usage information for the available options.
  final String usage;

  /// Creates a new [CliOptions] instance.
  const CliOptions({
    required this.verbose,
    required this.showHelp,
    required this.files,
    required this.usage,
  });

  /// Parses the command-line [args].
  ///
  /// Positional arguments are interpreted as the paths of the Dart files to
  /// analyze. When none are provided, every Dart file under `lib/` is
  /// analyzed.
  ///
  /// Throws a [FormatException] when an unknown option is provided.
  factory CliOptions.parse(List<String> args) {
    final parser = _buildParser();
    final results = parser.parse(args);

    return CliOptions(
      verbose: results['verbose'] as bool,
      showHelp: results['help'] as bool,
      files: List.unmodifiable(results.rest),
      usage: _buildUsage(parser),
    );
  }

  static ArgParser _buildParser() {
    return ArgParser()
      ..addFlag(
        'verbose',
        abbr: 'v',
        negatable: false,
        help: 'Print every file, import, and pattern check performed.',
      )
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Print this usage information.',
      );
  }

  static String _buildUsage(ArgParser parser) {
    return 'Usage: dart run eagle_eye:main [options] [file ...]\n'
        '\n'
        'Analyzes the given Dart files. When no files are provided, analyzes '
        'every Dart file under lib/.\n'
        '\n'
        '${parser.usage}';
  }
}
