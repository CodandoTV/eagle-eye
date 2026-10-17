import 'package:eagle_eye/util/cli_options.dart';
import 'package:test/test.dart';

void main() {
  group('CliOptions', () {
    test('defaults to non-verbose without help', () {
      final options = CliOptions.parse([]);

      expect(options.verbose, isFalse);
      expect(options.showHelp, isFalse);
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
    });
  });
}
