import 'package:eagle_eye/model/error_info.dart';
import 'package:eagle_eye/model/software_unit.dart';
import 'package:eagle_eye/rules/do_not_with_rule_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'DoNotWithRuleChecker -> test not allowed imports',
    () {
      final softwareUnit = SoftwareUnit(
        filePath: 'lib/screens/my_beatiful_screen.dart',
        imports: ['import package:myapp/data/myapp_data_source.dart;'],
      );

      final checker = DoNotWithRuleChecker(
        notWithImports: {
          '*screen.dart': ['*data*', '*domain*']
        },
      );

      ErrorInfo? result = checker.check(softwareUnit: softwareUnit);
      expect(result?.violation, '*data*');
    },
  );

  test(
    'DoNotWithRuleChecker -> test allowed imports',
    () {
      final softwareUnit = SoftwareUnit(
        filePath: 'lib/screens/my_beatiful_screen.dart',
        imports: ['import package:myapp/screens/my_beatiful_view_model.dart;'],
      );

      final checker = DoNotWithRuleChecker(
        notWithImports: {
          '*screen.dart': ['*data*', '*domain*']
        },
      );

      ErrorInfo? result = checker.check(softwareUnit: softwareUnit);
      expect(result, null);
    },
  );
}
