import 'package:args/args.dart';

/// Parsed command-line options accepted by Eagle Eye.
class CliOptions {
  /// Whether verbose check tracing is enabled.
  final bool verbose;

  /// Whether the user requested the usage information.
  final bool showHelp;

  /// The usage information for the available options.
  final String usage;

  /// Creates a new [CliOptions] instance.
  const CliOptions({
    required this.verbose,
    required this.showHelp,
    required this.usage,
  });

  /// Parses the command-line [args].
  ///
  /// Throws a [FormatException] when an unknown option is provided.
  factory CliOptions.parse(List<String> args) {
    final parser = _buildParser();
    final results = parser.parse(args);

    return CliOptions(
      verbose: results['verbose'] as bool,
      showHelp: results['help'] as bool,
      usage: parser.usage,
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
}
