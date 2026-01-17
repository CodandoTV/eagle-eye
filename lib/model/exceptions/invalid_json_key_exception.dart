import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';

/// [InvalidJsonKeyException] defines an error deprecated
/// keys are used: doNotWithPatterns, justWithPatterns, and
/// noDependsEnabled.
class InvalidJsonKeyException extends EagleEyeException {
  /// Create [InvalidJsonKeyException] object
  InvalidJsonKeyException() {
    super.message = '❌ Invalid keys found in configuration file.'
        '\n\n'
        'The following keys have been discontinued and are no longer supported:'
        '\n'
        '• doNotWithPatterns\n'
        '• justWithPatterns\n'
        '• noDependsEnabled\n'
        '\n'
        'To fix this, please update your configuration to use the new naming '
        'convention:\n'
        '  - doNotWithPatterns      →  forbiddenDependencies\n'
        '  - justWithPatterns       →  exclusiveDependencies\n'
        '  - noDependsEnabled       →  dependenciesAllowed: false\n';
  }
}
