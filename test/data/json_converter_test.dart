import 'package:eagle_eye/data/json_converter.dart';
import 'package:eagle_eye/model/exceptions/invalid_config_exception.dart';
import 'package:eagle_eye/model/exceptions/invalid_json_key_exception.dart';
import 'package:test/test.dart';

void main() {
  group('JsonConverter', () {
    late JsonConverter converter;

    setUp(() {
      converter = JsonConverter();
    });

    Matcher throwsInvalidConfig(String expectedMessage) {
      return throwsA(
        isA<InvalidConfigException>().having(
          (e) => e.message,
          'message',
          contains(expectedMessage),
        ),
      );
    }

    test('converts a valid array of rules', () {
      final config = converter.convert(
        '[{"filePattern": "*_screen.dart", '
        '"forbiddenDependencies": ["*_data.dart"]}]',
      );

      expect(config.items, hasLength(1));
      expect(config.items.first.filePattern, '*_screen.dart');
      expect(config.items.first.forbiddenDependencies, ['*_data.dart']);
    });

    test('rejects malformed JSON', () {
      expect(
        () => converter.convert('not a json'),
        throwsInvalidConfig('not valid JSON'),
      );
    });

    test('rejects a top-level value that is not an array', () {
      expect(
        () => converter.convert('{"filePattern": "*"}'),
        throwsInvalidConfig('must contain a JSON array'),
      );
    });

    test('rejects an item that is not an object', () {
      expect(
        () => converter.convert('[1]'),
        throwsInvalidConfig('Rule #1 must be a JSON object'),
      );
    });

    test('rejects a rule without filePattern', () {
      expect(
        () => converter.convert('[{"name": "no-pattern"}]'),
        throwsInvalidConfig('Rule #1'),
      );
    });

    test('rejects an empty filePattern', () {
      expect(
        () => converter.convert('[{"filePattern": "  "}]'),
        throwsInvalidConfig('filePattern'),
      );
    });

    test('rejects a non-boolean dependenciesAllowed', () {
      expect(
        () => converter.convert(
          '[{"filePattern": "*", "dependenciesAllowed": "false"}]',
        ),
        throwsInvalidConfig('dependenciesAllowed'),
      );
    });

    test('rejects forbiddenDependencies that is not a list', () {
      expect(
        () => converter.convert(
          '[{"filePattern": "*", "forbiddenDependencies": "*_data.dart"}]',
        ),
        throwsInvalidConfig('forbiddenDependencies'),
      );
    });

    test('rejects dependency lists containing non-strings', () {
      expect(
        () => converter.convert(
          '[{"filePattern": "*", "exclusiveDependencies": [1]}]',
        ),
        throwsInvalidConfig('exclusiveDependencies'),
      );
    });

    test('rejects a non-string name', () {
      expect(
        () => converter.convert('[{ "filePattern": "*", "name": 1}]'),
        throwsInvalidConfig('name'),
      );
    });

    test('rejects deprecated keys', () {
      expect(
        () => converter.convert(
          '[{"filePattern": "*", "doNotWithPatterns": ["*"]}]',
        ),
        throwsA(isA<InvalidJsonKeyException>()),
      );
    });
  });
}
