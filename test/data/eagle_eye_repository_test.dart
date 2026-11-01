import 'dart:io';

import 'package:eagle_eye/data/eagle_eye_repository.dart';
import 'package:eagle_eye/model/exceptions/config_file_not_found_exception.dart';
import 'package:eagle_eye/service_locator.dart';
import 'package:test/test.dart';

void main() {
  group('EagleEyeRepositoryImpl configuration path', () {
    late Directory originalDirectory;
    late Directory tempDirectory;
    late EagleEyeRepository repository;

    setUp(() {
      originalDirectory = Directory.current;
      tempDirectory = Directory.systemTemp.createTempSync('eagle_eye_repo');
      Directory.current = tempDirectory;
      repository = ServiceLocator().repository;
    });

    tearDown(() {
      Directory.current = originalDirectory;
      tempDirectory.deleteSync(recursive: true);
    });

    test('loads the configuration from a relative path', () async {
      File('${tempDirectory.path}/custom.json').writeAsStringSync(
        '[{"filePattern": "lib/*", "dependenciesAllowed": false}]',
      );

      final config = await repository.getAndCheckIfConfigFileExists(
        configPath: 'custom.json',
      );

      expect(config.items, hasLength(1));
      expect(config.items.single.filePattern, 'lib/*');
    });

    test('loads the configuration from an absolute path', () async {
      final file = File('${tempDirectory.path}/absolute.json')
        ..writeAsStringSync('[{"filePattern": "*"}]');

      final config = await repository.getAndCheckIfConfigFileExists(
        configPath: file.path,
      );

      expect(config.items.single.filePattern, '*');
    });

    test('falls back to eagle_eye_config.json', () async {
      File('${tempDirectory.path}/eagle_eye_config.json').writeAsStringSync(
        '[{"filePattern": "lib/model/*"}]',
      );

      final config = await repository.getAndCheckIfConfigFileExists();

      expect(config.items.single.filePattern, 'lib/model/*');
    });

    test('names the missing path in the error', () async {
      await expectLater(
        repository.getAndCheckIfConfigFileExists(configPath: 'missing.json'),
        throwsA(
          isA<ConfigFileNotFoundException>().having(
            (exception) => exception.message,
            'message',
            contains('missing.json'),
          ),
        ),
      );
    });
  });
}
