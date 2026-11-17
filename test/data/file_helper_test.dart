import 'dart:io';

import 'package:eagle_eye/data/file_helper.dart';
import 'package:eagle_eye/model/exceptions/empty_dart_file_list_exception.dart';
import 'package:eagle_eye/model/exceptions/invalid_file_selection_exception.dart';
import 'package:test/test.dart';

void main() {
  group('FileHelper.toCanonicalPath', () {
    late FileHelper fileHelper;

    setUp(() {
      fileHelper = FileHelper();
    });

    test('converts Windows separators to forward slashes', () {
      expect(
        fileHelper.toCanonicalPath(r'lib\domain\user.dart'),
        'lib/domain/user.dart',
      );
    });

    test('accepts mixed separators', () {
      expect(
        fileHelper.toCanonicalPath(r'lib\domain/user.dart'),
        'lib/domain/user.dart',
      );
    });

    test('collapses repeated, current and parent segments', () {
      expect(
        fileHelper.toCanonicalPath('lib//domain/./user.dart'),
        'lib/domain/user.dart',
      );
      expect(
        fileHelper.toCanonicalPath('lib/domain/../data/user.dart'),
        'lib/data/user.dart',
      );
    });

    test('leaves posix paths unchanged', () {
      expect(
        fileHelper.toCanonicalPath('lib/domain/user.dart'),
        'lib/domain/user.dart',
      );
    });
  });

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

  group('FileHelper.selectDartFiles', () {
    late FileHelper fileHelper;
    late Directory directory;
    late File first;
    late File second;
    late File third;

    setUp(() {
      fileHelper = FileHelper();
      directory = Directory.systemTemp.createTempSync('eagle_eye_selection');
      first = File('${directory.path}/first.dart')..writeAsStringSync('');
      second = File('${directory.path}/second.dart')..writeAsStringSync('');
      third = File('${directory.path}/third.dart')..writeAsStringSync('');
    });

    tearDown(() {
      directory.deleteSync(recursive: true);
    });

    test('selects requested files preserving their order', () {
      final selected = fileHelper.selectDartFiles(
        availableFiles: [first.path, second.path, third.path],
        requestedFiles: [third.path, first.path],
      );

      expect(selected, [
        fileHelper.toCanonicalPath(third.path),
        fileHelper.toCanonicalPath(first.path),
      ]);
    });

    test('selects a Windows-style spelling of an available file', () {
      final windowsSpelling = first.path.replaceAll('/', r'\');

      final selected = fileHelper.selectDartFiles(
        availableFiles: [first.path, second.path],
        requestedFiles: [windowsSpelling],
      );

      expect(selected, [fileHelper.toCanonicalPath(first.path)]);
      expect(selected.single.contains(r'\'), isFalse);
    });

    test('reports the canonical form of an invalid Windows-style path', () {
      final missing = File('${directory.path}/missing.dart');
      final windowsSpelling = missing.path.replaceAll('/', r'\');

      expect(
        () => fileHelper.selectDartFiles(
          availableFiles: [first.path],
          requestedFiles: [windowsSpelling],
        ),
        throwsA(
          isA<InvalidFileSelectionException>().having(
            (exception) => exception.message,
            'message',
            allOf(contains('/missing.dart'), isNot(contains(r'\'))),
          ),
        ),
      );
    });

    test('removes duplicate requests', () {
      final selected = fileHelper.selectDartFiles(
        availableFiles: [first.path, second.path],
        requestedFiles: [first.path, first.path, second.path],
      );

      expect(selected, [
        fileHelper.toCanonicalPath(first.path),
        fileHelper.toCanonicalPath(second.path),
      ]);
    });

    test('returns every available file when nothing is requested', () {
      final selected = fileHelper.selectDartFiles(
        availableFiles: [first.path, second.path],
        requestedFiles: const [],
      );

      expect(selected, [
        fileHelper.toCanonicalPath(first.path),
        fileHelper.toCanonicalPath(second.path),
      ]);
    });

    test('throws when a requested file does not exist', () {
      final missing = File('${directory.path}/missing.dart');

      expect(
        () => fileHelper.selectDartFiles(
          availableFiles: [first.path],
          requestedFiles: [missing.path],
        ),
        throwsA(
          isA<InvalidFileSelectionException>().having(
            (exception) => exception.message,
            'message',
            contains('does not exist'),
          ),
        ),
      );
    });

    test('throws when a requested path is not a Dart file', () {
      final notes = File('${directory.path}/notes.txt')
        ..writeAsStringSync('');

      expect(
        () => fileHelper.selectDartFiles(
          availableFiles: [first.path],
          requestedFiles: [notes.path],
        ),
        throwsA(
          isA<InvalidFileSelectionException>().having(
            (exception) => exception.message,
            'message',
            contains('is not a Dart (.dart) file'),
          ),
        ),
      );
    });

    test('throws when a requested file is outside the available list', () {
      final outside = File('${directory.path}/outside.dart')
        ..writeAsStringSync('');

      expect(
        () => fileHelper.selectDartFiles(
          availableFiles: [first.path],
          requestedFiles: [outside.path],
        ),
        throwsA(
          isA<InvalidFileSelectionException>().having(
            (exception) => exception.message,
            'message',
            contains('is outside lib/'),
          ),
        ),
      );
    });

    test('reports every invalid path at once', () {
      final missing = File('${directory.path}/missing.dart');
      final notes = File('${directory.path}/notes.txt')
        ..writeAsStringSync('');

      expect(
        () => fileHelper.selectDartFiles(
          availableFiles: [first.path],
          requestedFiles: [missing.path, notes.path],
        ),
        throwsA(
          isA<InvalidFileSelectionException>().having(
            (exception) => exception.message,
            'message',
            allOf(contains('missing.dart'), contains('notes.txt')),
          ),
        ),
      );
    });
  });
}
