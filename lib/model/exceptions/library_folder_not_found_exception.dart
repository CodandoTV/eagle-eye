import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';

/// [ConfigFileNotFoundException] defines an exception when
/// the configuration file is missing.
class LibraryFolderNotFoundException extends EagleEyeException {
  /// Create [LibraryFolderNotFoundException] object
  LibraryFolderNotFoundException() {
    super.message = '❌ libs folder was not found';
  }
}
