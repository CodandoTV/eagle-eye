import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:eagle_eye/analyzer/eagle_eye_visitor.dart';
import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/violation.dart';
import 'package:test/test.dart';

void main() {
  group('EagleEyeVisitor', () {
    List<Violation> analyze({
      required String source,
      required EagleEyeConfigItem configItem,
      required List<String> messages,
    }) {
      final unit = parseString(content: source).unit;
      final violations = <Violation>[];

      final visitor = EagleEyeVisitor(
        configItem: configItem,
        filePath: 'lib/model/user.dart',
        applicationName: 'my_app',
        errorCallback: violations.add,
        regexHelper: RegexHelper(),
        unit: unit,
        onCheck: messages.add,
      );
      unit.visitChildren(visitor);

      return violations;
    }

    test('logs internal imports and skips external imports', () {
      final messages = <String>[];
      final violations = analyze(
        source: "import 'package:my_app/data/repo.dart';\n"
            "import 'package:flutter/material.dart';\n",
        configItem: EagleEyeConfigItem(
          filePattern: '*/model/*',
          dependenciesAllowed: false,
          name: 'models-no-imports',
        ),
        messages: messages,
      );

      expect(violations, hasLength(1));
      expect(violations.single.ruleType, RuleType.noImportsAllowed);
      expect(
        messages,
        contains(
          '  internal import "package:my_app/data/repo.dart" (line 1)',
        ),
      );
      expect(
        messages,
        contains('    dependenciesAllowed is false -> violation'),
      );
      expect(
        messages,
        contains(
          '  skipping external import "package:flutter/material.dart" '
          '(line 2)',
        ),
      );
    });

    test('logs every forbidden pattern checked', () {
      final messages = <String>[];
      final violations = analyze(
        source: "import 'package:my_app/ui/home_screen.dart';\n",
        configItem: EagleEyeConfigItem(
          filePattern: '*/model/*',
          forbiddenDependencies: ['*_view.dart', '*_screen.dart'],
          name: 'models-no-screens',
        ),
        messages: messages,
      );

      expect(violations, hasLength(1));
      expect(violations.single.ruleType, RuleType.forbiddenDependency);
      expect(
        messages,
        contains('    rule type: forbiddenDependencies'),
      );
      expect(
        messages,
        contains('    forbidden pattern "*_view.dart": no match'),
      );
      expect(
        messages,
        contains(
          '    forbidden pattern "*_screen.dart": match -> violation',
        ),
      );
    });

    test('logs every exclusive pattern checked', () {
      final messages = <String>[];
      final violations = analyze(
        source: "import 'package:my_app/ui/home_widget.dart';\n",
        configItem: EagleEyeConfigItem(
          filePattern: '*/model/*',
          exclusiveDependencies: ['*_viewmodel.dart', '*_widget.dart'],
          name: 'models-only-ui',
        ),
        messages: messages,
      );

      expect(violations, isEmpty);
      expect(
        messages,
        contains('    rule type: exclusiveDependencies'),
      );
      expect(
        messages,
        contains('    allowed pattern "*_viewmodel.dart": no match'),
      );
      expect(
        messages,
        contains('    allowed pattern "*_widget.dart": match -> allowed'),
      );
    });

    test('reports a violation when no exclusive pattern matches', () {
      final messages = <String>[];
      final violations = analyze(
        source: "import 'package:my_app/data/repo.dart';\n",
        configItem: EagleEyeConfigItem(
          filePattern: '*/model/*',
          exclusiveDependencies: ['*_viewmodel.dart', '*_widget.dart'],
          name: 'models-only-ui',
        ),
        messages: messages,
      );

      expect(violations, hasLength(1));
      expect(violations.single.ruleType, RuleType.exclusiveDependency);
      expect(
        messages,
        contains('    allowed pattern "*_widget.dart": no match'),
      );
    });
  });
}
