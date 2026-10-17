import 'package:eagle_eye/analyzer/checker/forbidden_dependencies_rule_checker.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:test/test.dart';

void main() {
  group('ForbiddenDependenciesRuleChecker', () {
    test('returns description when a pattern matches', () {
      final regexHelper = RegexHelper();
      final checker = ForbiddenDependenciesRuleChecker(regexHelper);

      final result = checker.check(
        noDepsWithPatterns: ['*repository.dart'],
        importDirective: 'my_repository.dart',
        filePath: 'lib/my_screen.dart',
      );

      expect(
        result,
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

    test('reports each forbidden pattern checked until a match', () {
      final messages = <String>[];
      final checker = ForbiddenDependenciesRuleChecker(
        RegexHelper(),
        onCheck: messages.add,
      );

      checker.check(
        noDepsWithPatterns: ['*repository.dart', '*service.dart'],
        importDirective: 'my_service.dart',
        filePath: 'lib/my_screen.dart',
      );

      expect(messages, [
        '    forbidden pattern "*repository.dart": no match',
        '    forbidden pattern "*service.dart": match -> violation',
      ]);
    });
  });
}
