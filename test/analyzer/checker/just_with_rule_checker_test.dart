import 'package:eagle_eye/analyzer/checker/just_with_rule_checker.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:test/test.dart';

void main() {
  group('JustWithRuleChecker', () {
    test('returns ErrorInfo when a pattern matches', () {
      final regexHelper = RegexHelper();
      final checker = JustWithRuleChecker(regexHelper);

      final result = checker.check(
        justWithPatterns: ['*repository.dart'],
        importDirective: 'my_helper.dart',
        filePath: 'lib/my_screen.dart',
      );

      expect(
        result!.errorMessage,
        'lib/my_screen.dart should depends only on [*repository.dart]',
      );
    });

    test('returns null when no patterns match', () {
      final regexHelper = RegexHelper();
      final checker = JustWithRuleChecker(regexHelper);

      final result = checker.check(
        justWithPatterns: ['*repository.dart'],
        importDirective: 'my_repository.dart',
        filePath: 'lib/my_screen.dart',
      );

      expect(result, isNull);
    });
  });
}
