import 'dart:io';

import 'package:eagle_eye/data/config_item_mapper.dart';
import 'package:eagle_eye/data/eagle_eye_repository.dart';
import 'package:eagle_eye/data/file_helper.dart';
import 'package:eagle_eye/data/json_converter.dart';
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

    test('returns canonical paths for discovered files', () {
      final repository = EagleEyeRepositoryImpl(
        fileHelper: _FakeFileHelper([File(r'lib\domain\user.dart')]),
        jsonConverter: JsonConverter(mapper: ConfigItemMapper()),
      );

      expect(repository.allDartPaths(), ['lib/domain/user.dart']);
    });

    test('normalizes Windows-style requested paths', () {
      Directory('${tempDirectory.path}/lib/domain').createSync(recursive: true);
      File(
        '${tempDirectory.path}/lib/domain/user.dart',
      ).writeAsStringSync('');

      final paths = repository.dartPathsFor([r'lib\domain\user.dart']);

      expect(paths, ['lib/domain/user.dart']);
    });
  });
}

/// [FileHelper] that reports a fixed set of discovered files.
///
/// Discovery is the only layer that touches the file system, so faking it
/// lets the test feed a Windows-style path that `Directory.listSync` would
/// never produce on Linux or macOS.
class _FakeFileHelper extends FileHelper {
  _FakeFileHelper(this.files);

  final List<File> files;

  @override
  Directory getAndCheckIfLibsDirectoryExists(String libsFolderName) {
    return Directory(libsFolderName);
  }

  @override
  List<File> allDartFiles(Directory directory) => files;
}
