class EagleEyeConfigItem {
  bool? noDependsEnabled = false;
  List<String>? noDepsWithPatterns;
  List<String>? justDepsWithPatterns;
  String filePattern;

  EagleEyeConfigItem({
    this.noDependsEnabled,
    this.noDepsWithPatterns,
    this.justDepsWithPatterns,
    required this.filePattern,
  });
}
