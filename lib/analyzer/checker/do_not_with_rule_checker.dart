import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/error_info.dart';

class DoNotWithRuleChecker {
  RegexHelper regexHelper;

  DoNotWithRuleChecker(this.regexHelper);

  ErrorInfo? check({
    required List<String> noDepsWithPatterns,
    required String importDirective,
    required String filePath,
  }) {
    for (var noDepsWithItem in noDepsWithPatterns) {
      var matches = regexHelper.matchesPattern(
        importDirective,
        noDepsWithItem,
      );
      if (matches == true) {
        return ErrorInfo(
          filePath: filePath,
          errorMessage: '$filePath should not depends on $importDirective',
        );
      }
    }
    return null;
  }
}
