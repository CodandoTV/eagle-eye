import 'package:eagle_eye/model/exceptions/eagle_eye_exception.dart';

/// [EmptyDartFileListException] defines an exception when
/// no dart file was founded.
class EmptyDartFileListException extends EagleEyeException {
  /// Creates [EmptyDartFileListException] object
  EmptyDartFileListException() {
    super.message = '❌ Unable to load the dart files of your project.';
  }
}
