import 'package:eagle_eye/model/error_info.dart';
import 'package:eagle_eye/model/software_unit.dart';
import 'package:eagle_eye/rules/just_with_rule_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'JustWithRuleChecker -> test not allowed imports',
    () {
      final softwareUnit = SoftwareUnit(
        filePath: 'lib/screens/my_beatiful_screen.dart',
        imports: [
          'import package:myapp/data/myapp_data_source.dart;',
          'import package:myapp/screens/my_beautiful_viewmodel.dart'
        ],
      );

      final checker = JustWithRuleChecker(
        justWithImports: {
          '*screen.dart': [
            '*my_beautiful_viewmodel.dart',
          ]
        },
      );

      ErrorInfo? result = checker.check(softwareUnit: softwareUnit);
      expect(result?.violation, 'It is not a valid import');
      expect(
          result?.import, 'import package:myapp/data/myapp_data_source.dart;');
    },
  );

  test(
    'JustWithRuleChecker -> test allowed imports',
    () {
      final softwareUnit = SoftwareUnit(
        filePath: 'lib/screens/my_beatiful_screen.dart',
        imports: ['import package:myapp/screens/my_beatiful_view_model.dart;'],
      );

      final checker = JustWithRuleChecker(
        justWithImports: {
          '*screen.dart': [
            '*my_beatiful_view_model.dart',
          ]
        },
      );

      ErrorInfo? result = checker.check(softwareUnit: softwareUnit);
      expect(result, null);
    },
  );
}
