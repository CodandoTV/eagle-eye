import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';

/// [InvalidBaselineException] defines an exception thrown when the baseline
/// file cannot be parsed into a valid baseline.
class InvalidBaselineException extends EagleEyeException {
  /// Create [InvalidBaselineException] object
  InvalidBaselineException() {
    super.message = '❌ Unable to parse the baseline file. '
        'Please ensure eagle_eye_baseline.json is valid, or regenerate it '
        'with: dart run eagle_eye:main --baseline';
  }
}
