import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';

/// [InvalidFileSelectionException] defines an exception for file paths that
/// cannot be analyzed.
class InvalidFileSelectionException extends EagleEyeException {
  /// Creates [InvalidFileSelectionException] with the given [problems].
  InvalidFileSelectionException(List<String> problems) {
    final details = problems.map((problem) => '  • $problem').join('\n');
    super.message = '❌ Unable to analyze the requested file(s):\n$details';
  }
}
