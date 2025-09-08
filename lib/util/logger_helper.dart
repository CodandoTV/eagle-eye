class LoggerHelper {
  static bool debug = true;

  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _reset = '\x1B[0m';
  static const _eagleEmoji = '🦅';

  static void printError(String message) {
    print('$_eagleEmoji $_red$message$_reset');
  }

  static void printSuccess(String message) {
    print('$_eagleEmoji $_green$message$_reset');
  }

  static void printDebug(String message) {
    if (debug) {
      print('!!!!! $_red $message $_reset');
    }
  }
}
