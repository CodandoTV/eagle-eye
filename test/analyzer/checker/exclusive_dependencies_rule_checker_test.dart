import 'package:eagle_eye/analyzer/checker/exclusive_dependencies_rule_checker.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:test/test.dart';

void main() {
  group('ExclusiveDependenciesRuleChecker', () {
    test('returns description when a pattern does not match', () {
      final regexHelper = RegexHelper();
      final checker = ExclusiveDependenciesRuleChecker(regexHelper);

      final result = checker.check(
        justWithPatterns: ['*repository.dart'],
        importDirective: 'my_helper.dart',
        filePath: 'lib/my_screen.dart',
      );

      expect(
        result,
        'lib/my_screen.dart should depend only on [*repository.dart]',
      );
    });

    test('returns null when a pattern matches', () {
      final regexHelper = RegexHelper();
      final checker = ExclusiveDependenciesRuleChecker(regexHelper);

      final result = checker.check(
        justWithPatterns: ['*repository.dart'],
        importDirective: 'my_repository.dart',
        filePath: 'lib/my_screen.dart',
      );

      expect(result, isNull);
    });

    test('returns null when the import matches the second of many patterns',
        () {
      final regexHelper = RegexHelper();
      final checker = ExclusiveDependenciesRuleChecker(regexHelper);

      final result = checker.check(
        justWithPatterns: ['*_viewmodel.dart', '*_widget.dart'],
        importDirective: 'my_widget.dart',
        filePath: 'lib/my_screen.dart',
      );

      expect(result, isNull);
    });

    test('returns description when the import matches none of many patterns',
        () {
      final regexHelper = RegexHelper();
      final checker = ExclusiveDependenciesRuleChecker(regexHelper);

      final result = checker.check(
        justWithPatterns: ['*_viewmodel.dart', '*_widget.dart'],
        importDirective: 'my_helper.dart',
        filePath: 'lib/my_screen.dart',
      );

      expect(
        result,
        'lib/my_screen.dart should depend only on '
        '[*_viewmodel.dart, *_widget.dart]',
      );
    });
  });
}
