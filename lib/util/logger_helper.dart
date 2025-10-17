/// Utility class for logging messages to the console with optional formatting.
///
/// The [LoggerHelper] provides methods to print errors, success messages,
/// and debug information. It uses ANSI escape codes to add color to the output
/// and an eagle emoji 🦅 as a prefix for easier identification in logs.
class LoggerHelper {
  /// Enables or disables debug messages.
  static bool debug = true;

  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _reset = '\x1B[0m';
  static const _eagleEmoji = '🦅';

  /// Prints an error message in red with an eagle emoji prefix.
  ///
  /// Example:
  /// `🦅 <red>Error message</red>`
  static void printError(String message) {
    print('$_eagleEmoji $_red$message$_reset');
  }

  /// Prints a success message in green with an eagle emoji prefix.
  ///
  /// Example:
  /// `🦅 <green>Success message</green>`
  static void printSuccess(String message) {
    print('$_eagleEmoji $_green$message$_reset');
  }

  /// Prints a debug message if [debug] is `true`.
  ///
  /// The message is printed in red with a prefix `!!!!!` for visibility.
  static void printDebug(String message) {
    if (debug) {
      print('!!!!! $_red $message $_reset');
    }
  }
}
