import 'package:eagle_eye/util/cli_options.dart';
import 'package:test/test.dart';

void main() {
  group('CliOptions', () {
    test('defaults to non-verbose without help and no files', () {
      final options = CliOptions.parse([]);

      expect(options.verbose, isFalse);
      expect(options.showHelp, isFalse);
      expect(options.files, isEmpty);
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
      expect(options.usage, contains('[file ...]'));
    });
  });
}
