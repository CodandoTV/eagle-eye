import 'dart:io';

import 'package:eagle_eye/data/eagle_eye_repository.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/service_locator.dart';
import 'package:eagle_eye/util/cli_options.dart';
import 'package:test/test.dart';

void main() {
  group('ServiceLocator', () {
    late ServiceLocator locator;

    setUp(() {
      locator = ServiceLocator();
    });

    test('creates a repository implementation', () {
      expect(locator.repository, isA<EagleEyeRepositoryImpl>());
    });

    test('parses CLI options', () {
      final options = locator.parseCliOptions(['--verbose']);

      expect(options, isA<CliOptions>());
      expect(options.verbose, isTrue);
    });

    test('shares the same RegexHelper across factories', () {
      final config = EagleEyeConfig(
        items: [EagleEyeConfigItem(filePattern: '*')],
      );

      final matcher = locator.createMatcher(config: config);
      final validator = locator.createConfigValidator();

      expect(matcher.regexHelper, same(locator.regexHelper));
      expect(validator.regexHelper, same(locator.regexHelper));
    });

    test('exposes a Dart source loader', () {
      final directory = Directory.systemTemp.createTempSync('eagle_eye');
      addTearDown(() => directory.deleteSync(recursive: true));
      final file = File('${directory.path}/sample.dart');
      file.writeAsStringSync(
        "import 'package:eagle_eye/service_locator.dart';",
      );

      final unit = locator.dartSourceLoader.load(file.path);

      expect(unit.directives, hasLength(1));
    });
  });
}
