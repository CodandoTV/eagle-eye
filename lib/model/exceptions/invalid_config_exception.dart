import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';

/// [InvalidConfigException] defines an error for a configuration file that
/// cannot be parsed or contains invalid or conflicting rules.
class InvalidConfigException extends EagleEyeException {
  /// The detailed description of the configuration problem.
  final String details;

  /// Create [InvalidConfigException] object with the given [details].
  InvalidConfigException(this.details) {
    super.message =
        '❌ Invalid configuration file.'
        '\n\n'
        '$details';
  }
}
