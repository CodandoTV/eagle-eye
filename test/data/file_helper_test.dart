import 'dart:io';

import 'package:eagle_eye/data/file_helper.dart';
import 'package:eagle_eye/model/exceptions/empty_dart_file_list_exception.dart';
import 'package:test/test.dart';

void main() {
  group('FileHelper.allDartFiles', () {
    late FileHelper fileHelper;
    late Directory directory;

    setUp(() {
      fileHelper = FileHelper();
      directory = Directory.systemTemp.createTempSync('eagle_eye_files');
    });

    tearDown(() {
      directory.deleteSync(recursive: true);
    });

    test('returns every Dart file recursively', () {
      Directory('${directory.path}/nested').createSync();
      File('${directory.path}/root.dart').writeAsStringSync('');
      File('${directory.path}/nested/child.dart').writeAsStringSync('');
      File('${directory.path}/notes.txt').writeAsStringSync('');

      final files = fileHelper.allDartFiles(directory);

      expect(files, hasLength(2));
      expect(
        files.map((file) => file.uri.pathSegments.last),
        containsAll(['root.dart', 'child.dart']),
      );
    });

    test('throws when no Dart files exist', () {
      File('${directory.path}/notes.txt').writeAsStringSync('');

      expect(
        () => fileHelper.allDartFiles(directory),
        throwsA(isA<EmptyDartFileListException>()),
      );
    });
  });
}
