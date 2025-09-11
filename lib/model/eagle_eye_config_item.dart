class EagleEyeConfigItem {
  bool? noDependsEnabled = false;
  List<String>? noDepsWithPatterns;
  List<String>? justWithPatterns;
  String filePattern;

  EagleEyeConfigItem({
    this.noDependsEnabled,
    this.noDepsWithPatterns,
    this.justWithPatterns,
    required this.filePattern,
  });
}
