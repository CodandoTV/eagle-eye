import 'package:eagle_eye/analyzer/regex_helper.dart';
import 'package:eagle_eye/model/error_info.dart';

class JustWithRuleChecker {
  RegexHelper regexHelper;

  JustWithRuleChecker(this.regexHelper);

  ErrorInfo? check({
    required List<String> justWithPatterns,
    required String importDirective,
    required String filePath,
  }) {
    for (var justWithItem in justWithPatterns) {
      var matches = regexHelper.matchesPattern(
        importDirective,
        justWithItem,
      );
      if (matches == false) {
        return ErrorInfo(
          filePath: filePath,
          errorMessage: '$filePath should depends only on $justWithPatterns',
        );
      }
    }
    return null;
  }
}
