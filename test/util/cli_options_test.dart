import 'package:eagle_eye/util/cli_options.dart';
import 'package:test/test.dart';

void main() {
  group('CliOptions', () {
    test('defaults to non-verbose without help and no files', () {
      final options = CliOptions.parse([]);

      expect(options.verbose, isFalse);
      expect(options.showHelp, isFalse);
      expect(options.files, isEmpty);
      expect(options.configPath, isNull);
    });

    test('collects positional file paths in order', () {
      final options = CliOptions.parse(['lib/a.dart', 'lib/b.dart']);

      expect(options.files, ['lib/a.dart', 'lib/b.dart']);
    });

    test('collects positional files alongside options', () {
      final options = CliOptions.parse(['lib/a.dart', '--verbose']);

      expect(options.verbose, isTrue);
      expect(options.files, ['lib/a.dart']);
    });

    test('parses the configuration path with --config', () {
      final options = CliOptions.parse(['--config', 'custom.json']);

      expect(options.configPath, 'custom.json');
    });

    test('parses the configuration path with -c', () {
      final options = CliOptions.parse(['-c', 'custom.json']);

      expect(options.configPath, 'custom.json');
    });

    test('parses the configuration path alongside files', () {
      final options = CliOptions.parse([
        '--config',
        'custom.json',
        'lib/a.dart',
      ]);

      expect(options.configPath, 'custom.json');
      expect(options.files, ['lib/a.dart']);
    });

    test('enables verbose with --verbose', () {
      final options = CliOptions.parse(['--verbose']);

      expect(options.verbose, isTrue);
    });

    test('enables verbose with -v', () {
      final options = CliOptions.parse(['-v']);

      expect(options.verbose, isTrue);
    });

    test('enables help with --help', () {
      final options = CliOptions.parse(['--help']);

      expect(options.showHelp, isTrue);
    });

    test('throws FormatException for unknown options', () {
      expect(
        () => CliOptions.parse(['--unknown']),
        throwsFormatException,
      );
    });

    test('exposes usage text for the supported options', () {
      final options = CliOptions.parse([]);

      expect(options.usage, contains('--verbose'));
      expect(options.usage, contains('--help'));
      expect(options.usage, contains('--config'));
      expect(options.usage, contains('[file ...]'));
    });
  });
}
