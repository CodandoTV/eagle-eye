/// Represents a violation detected by the Eagle Eye analysis.
///
/// Each [AnalysisErrorInfo] instance contains the path of the file
/// where the violation occurred ([filePath]) and a descriptive message
/// explaining the issue ([errorMessage]).
class AnalysisErrorInfo {
  /// The path of the file where the error was detected.
  String filePath;

  /// A descriptive message explaining the violation.
  String errorMessage;

  /// Creates a new [AnalysisErrorInfo] instance with the given [filePath]
  /// and [errorMessage].
  AnalysisErrorInfo({
    required this.filePath,
    required this.errorMessage,
  });
}
