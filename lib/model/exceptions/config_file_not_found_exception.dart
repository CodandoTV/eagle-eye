import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';

/// [ConfigFileNotFoundException] defines an exception when
/// the configuration file is missing.
class ConfigFileNotFoundException extends EagleEyeException {
  /// Create [ConfigFileNotFoundException] object
  ConfigFileNotFoundException() {
    super.message = '❌ Unable to load configuration file. '
        'Please ensure that an eagle_eye_config.json file exists at the '
        'root of your project.';
  }
}
