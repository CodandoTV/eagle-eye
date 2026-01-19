import 'package:eagle_eye/analyzer/checker/forbidden_dependencies_rule_checker.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:test/test.dart';

void main() {
  group('ForbiddenDependenciesRuleChecker', () {
    test('returns ErrorInfo when a pattern matches', () {
      final regexHelper = RegexHelper();
      final checker = ForbiddenDependenciesRuleChecker(regexHelper);

      final result = checker.check(
        noDepsWithPatterns: ['*repository.dart'],
        importDirective: 'my_repository.dart',
        filePath: 'lib/my_screen.dart',
      );

      expect(
        result!.errorMessage,
        'lib/my_screen.dart should not depends on my_repository.dart',
      );
    });

    test('returns null when no patterns match', () {
      final regexHelper = RegexHelper();
      final checker = ForbiddenDependenciesRuleChecker(regexHelper);

      final result = checker.check(
        noDepsWithPatterns: ['*repository.dart'],
        importDirective: 'my_helper_class.dart',
        filePath: 'lib/my_screen.dart',
      );

      expect(result, isNull);
    });
  });
}
