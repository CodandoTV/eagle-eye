import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';

/// [ConfigFileNotFoundException] defines an exception when
/// the configuration file is missing.
class ConfigFileNotFoundException extends EagleEyeException {
  /// Create [ConfigFileNotFoundException] object.
  ///
  /// When [configPath] is provided, the message names that path. Otherwise it
  /// keeps the default project-root wording.
  ConfigFileNotFoundException([String? configPath]) {
    final String location = configPath == null
        ? 'an eagle_eye_config.json file exists at the root of your project'
        : '"$configPath" exists';
    super.message = '❌ Unable to load configuration file. '
        'Please ensure that $location.';
  }
}
