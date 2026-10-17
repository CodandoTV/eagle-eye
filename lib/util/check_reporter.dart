/// Reports a verbose message describing a check performed by Eagle Eye.
///
/// When verbose mode is enabled, a [CheckReporter] is passed through the
/// analyzer so every configuration, file, import, and pattern check can be
/// printed to the console.
typedef CheckReporter = void Function(String message);
