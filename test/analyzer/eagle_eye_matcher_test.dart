import 'package:eagle_eye/analyzer/eagle_eye_matcher.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:test/test.dart';

// --- Tests ---
void main() {
  group('EagleEyeMatcher', () {
    late RegexHelper regexHelper;

    setUp(() {
      regexHelper = RegexHelper();
    });

    test('returns matching config item when pattern matches', () {
      final item = EagleEyeConfigItem(
        filePattern: '*screen.dart',
      );
      final config = EagleEyeConfig(items: [item]);

      final matcher = EagleEyeMatcher(
        config: config,
        regexHelper: regexHelper,
      );

      final result = matcher.find('home_screen.dart');

      expect(result, equals(item));
    });

    test('returns null when no patterns match', () {
      final item = EagleEyeConfigItem(filePattern: '*widget.dart');
      final config = EagleEyeConfig(items: [item]);

      final matcher = EagleEyeMatcher(
        config: config,
        regexHelper: regexHelper,
      );

      final result = matcher.find('home_screen.dart');

      expect(result, isNull);
    });

    test('returns first matching item when multiple match', () {
      final item1 = EagleEyeConfigItem(filePattern: '*screen.dart');
      final item2 = EagleEyeConfigItem(filePattern: '*home.dart');
      final config = EagleEyeConfig(items: [item1, item2]);

      final matcher = EagleEyeMatcher(
        config: config,
        regexHelper: regexHelper,
      );

      final result = matcher.find('home_screen.dart');

      // The first matching item should be returned
      expect(result, equals(item1));
    });
  });
}
