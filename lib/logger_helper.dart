class LoggerHelper {
  static const red = '\x1B[31m';
  static const green = '\x1B[32m';
  static const reset = '\x1B[0m';
  static const eagleEmoji = '🦅';

  static void printError(String message) {
    print('$eagleEmoji $red$message$reset');
  }

  static void printSuccess(String message) {
    print('$eagleEmoji $green$message$reset');
  }
}
