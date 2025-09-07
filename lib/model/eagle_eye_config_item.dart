class EagleEyeConfigItem {
  bool? noDependsEnabled = false;
  List<String>? noDepsWithPatterns;
  String filePattern;

  EagleEyeConfigItem({
    this.noDependsEnabled,
    this.noDepsWithPatterns,
    required this.filePattern,
  });
}
