import 'dart:io';

import 'package:eagle_eye/data/dart_source_loader.dart';
import 'package:test/test.dart';

void main() {
  group('DartSourceLoader', () {
    late DartSourceLoader loader;
    late Directory directory;

    setUp(() {
      loader = DartSourceLoader();
      directory = Directory.systemTemp.createTempSync('eagle_eye_loader');
    });

    tearDown(() {
      directory.deleteSync(recursive: true);
    });

    test('parses a Dart file into a compilation unit', () {
      final file = File('${directory.path}/sample.dart');
      file.writeAsStringSync(
        "import 'package:eagle_eye/service_locator.dart';",
      );

      final unit = loader.load(file.path);

      expect(unit.directives, hasLength(1));
    });
  });
}
