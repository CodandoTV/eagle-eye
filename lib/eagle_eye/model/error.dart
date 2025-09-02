
class Error {
  final String filePath;
  final String import;
  final String violation;

  Error({
    required this.filePath,
    required this.import,
    required this.violation,
  });
}
