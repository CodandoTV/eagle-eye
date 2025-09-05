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

  factory EagleEyeConfigItem.fromJson(Map<String, dynamic> json) {
    return EagleEyeConfigItem(
      noDependsEnabled: json['noDependsEnabled'],
      noDepsWithPatterns: json['noDepsWithPatterns'],
      justDepsWithPatterns: json['justDepsWithPatterns'],
      filePattern: json['filePattern'],
    );
  }
}
