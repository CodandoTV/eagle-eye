/// [ApplicationNameNotFoundException] defines an exception when
/// the application name is not specified at pubspec.yaml file.
class ApplicationNameNotFoundException implements Exception {
  /// User friendly message describing the issue.
  final String message = '❌ Unable to detect the name of you app. '
      'Please define it in your pubspec.yaml.';

  /// Creates [ApplicationNameNotFoundException] object
  ApplicationNameNotFoundException();
}
