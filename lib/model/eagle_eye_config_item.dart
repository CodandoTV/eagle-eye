class EagleEyeConfigItem {
  bool? noDependsEnabled = false;
  List<String>? doNotWithPatterns;
  List<String>? justWithPatterns;
  String filePattern;

  EagleEyeConfigItem({
    this.noDependsEnabled,
    this.doNotWithPatterns,
    this.justWithPatterns,
    required this.filePattern,
  });
}
