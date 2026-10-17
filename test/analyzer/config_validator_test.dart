import 'package:eagle_eye/analyzer/config_validator.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/exceptions/invalid_config_exception.dart';
import 'package:test/test.dart';

void main() {
  group('EagleEyeConfigValidator', () {
    late EagleEyeConfigValidator validator;

    setUp(() {
      validator = EagleEyeConfigValidator(regexHelper: RegexHelper());
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

    test('accepts a config where each file matches at most one rule', () {
      final config = EagleEyeConfig(
        items: [
          EagleEyeConfigItem(
            filePattern: '*/data/*',
            dependenciesAllowed: false,
          ),
          EagleEyeConfigItem(filePattern: '*_screen.dart'),
        ],
      );

      expect(
        () => validator.validate(
          config: config,
          filePaths: [
            'lib/data/user_repository.dart',
            'lib/presentation/home_screen.dart',
          ],
        ),
        returnsNormally,
      );
    });

    test('rejects a file matched by more than one rule', () {
      final config = EagleEyeConfig(
        items: [
          EagleEyeConfigItem(
            filePattern: '*/features/*/data/*',
            name: 'feature-data',
          ),
          EagleEyeConfigItem(
            filePattern: '*_repository.dart',
            name: 'repositories',
          ),
        ],
      );

      expect(
        () => validator.validate(
          config: config,
          filePaths: ['lib/features/auth/data/user_repository.dart'],
        ),
        throwsInvalidConfig('Each file must match exactly one rule'),
      );

      expect(
        () => validator.validate(
          config: config,
          filePaths: ['lib/features/auth/data/user_repository.dart'],
        ),
        throwsInvalidConfig('Rule #1 ("feature-data")'),
      );
    });

    test('accepts overlapping patterns that never co-match a real file', () {
      final config = EagleEyeConfig(
        items: [
          EagleEyeConfigItem(filePattern: '*/features/*'),
          EagleEyeConfigItem(filePattern: '*_screen.dart'),
        ],
      );

      expect(
        () => validator.validate(
          config: config,
          filePaths: [
            'lib/features/auth/data/user.dart',
            'lib/presentation/home_screen.dart',
          ],
        ),
        returnsNormally,
      );
    });

    test('rejects duplicate patterns when a file matches both rules', () {
      final config = EagleEyeConfig(
        items: [
          EagleEyeConfigItem(filePattern: '*_repository.dart'),
          EagleEyeConfigItem(filePattern: '*_repository.dart'),
        ],
      );

      expect(
        () => validator.validate(
          config: config,
          filePaths: ['lib/data/user_repository.dart'],
        ),
        throwsInvalidConfig('Rule #2'),
      );
    });

    test('does not report conflicts when there are no files', () {
      final config = EagleEyeConfig(
        items: [
          EagleEyeConfigItem(filePattern: '*'),
          EagleEyeConfigItem(filePattern: '*.dart'),
        ],
      );

      expect(
        () => validator.validate(config: config, filePaths: []),
        returnsNormally,
      );
    });

    test('rejects an empty filePattern', () {
      final config = EagleEyeConfig(
        items: [EagleEyeConfigItem(filePattern: '  ')],
      );

      expect(
        () => validator.validate(config: config, filePaths: []),
        throwsInvalidConfig('has an empty "filePattern"'),
      );
    });

    test('rejects an invalid filePattern regex', () {
      final config = EagleEyeConfig(
        items: [EagleEyeConfigItem(filePattern: '*[abc')],
      );

      expect(
        () => validator.validate(config: config, filePaths: []),
        throwsInvalidConfig('has an invalid "filePattern"'),
      );
    });

    test('rejects an invalid dependency pattern regex', () {
      final config = EagleEyeConfig(
        items: [
          EagleEyeConfigItem(
            filePattern: '*_screen.dart',
            forbiddenDependencies: ['[abc'],
          ),
        ],
      );

      expect(
        () => validator.validate(config: config, filePaths: []),
        throwsInvalidConfig('invalid forbiddenDependencies pattern'),
      );
    });

    test(
      'rejects dependenciesAllowed false combined with forbiddenDependencies',
      () {
        final config = EagleEyeConfig(
          items: [
            EagleEyeConfigItem(
              filePattern: '*_screen.dart',
              dependenciesAllowed: false,
              forbiddenDependencies: ['*_data.dart'],
            ),
          ],
        );

        expect(
          () => validator.validate(config: config, filePaths: []),
          throwsInvalidConfig('defines more than one constraint'),
        );
      },
    );

    test(
      'rejects forbiddenDependencies combined with exclusiveDependencies',
      () {
        final config = EagleEyeConfig(
          items: [
            EagleEyeConfigItem(
              filePattern: '*_screen.dart',
              forbiddenDependencies: ['*_data.dart'],
              exclusiveDependencies: ['*_widget.dart'],
            ),
          ],
        );

        expect(
          () => validator.validate(config: config, filePaths: []),
          throwsInvalidConfig('defines more than one constraint'),
        );
      },
    );

    test('allows dependenciesAllowed true combined with a dependency list', () {
      final config = EagleEyeConfig(
        items: [
          EagleEyeConfigItem(
            filePattern: '*_screen.dart',
            dependenciesAllowed: true,
            forbiddenDependencies: ['*_data.dart'],
          ),
        ],
      );

      expect(
        () => validator.validate(config: config, filePaths: []),
        returnsNormally,
      );
    });

    test(
      'allows an empty dependency list combined with another constraint',
      () {
        final config = EagleEyeConfig(
          items: [
            EagleEyeConfigItem(
              filePattern: '*_screen.dart',
              forbiddenDependencies: [],
              exclusiveDependencies: ['*_widget.dart'],
            ),
          ],
        );

        expect(
          () => validator.validate(config: config, filePaths: []),
          returnsNormally,
        );
      },
    );

    test('reports the validation step through onCheck', () {
      final messages = <String>[];
      final validating = EagleEyeConfigValidator(
        regexHelper: RegexHelper(),
        onCheck: messages.add,
      );
      final config = EagleEyeConfig(
        items: [EagleEyeConfigItem(filePattern: '*_screen.dart')],
      );

      validating.validate(config: config, filePaths: ['lib/home_screen.dart']);

      expect(messages, ['Validating 1 rule(s) against 1 file(s)']);
    });
  });
}
