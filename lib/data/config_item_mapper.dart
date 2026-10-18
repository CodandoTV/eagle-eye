import 'package:eagle_eye/data/config_keys.dart';
import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:eagle_eye/model/exceptions/invalid_config_exception.dart';

/// Maps configuration JSON objects into [EagleEyeConfigItem] instances.
///
/// This is a data-layer concern: the model stays free of wire-format
/// knowledge, while the mapper owns key names and type validation.
class ConfigItemMapper {
  /// Maps a single JSON object into an [EagleEyeConfigItem].
  ///
  /// Throws an [InvalidConfigException] when a required field is missing or
  /// when a field has an unexpected type.
  EagleEyeConfigItem map(Map<String, dynamic> json) {
    final dependenciesAllowed = _readDependenciesAllowed(json);
    final forbiddenDependencies = _readStringList(
      json,
      ConfigKeys.forbiddenDependenciesEagleItemKey,
    );
    final exclusiveDependencies = _readStringList(
      json,
      ConfigKeys.exclusiveDependenciesEagleItemKey,
    );
    final filePattern = _readFilePattern(json);
    final name = _readName(json);

    return EagleEyeConfigItem(
      dependenciesAllowed: dependenciesAllowed,
      forbiddenDependencies: forbiddenDependencies,
      exclusiveDependencies: exclusiveDependencies,
      filePattern: filePattern,
      name: name,
    );
  }

  bool? _readDependenciesAllowed(Map<String, dynamic> json) {
    final key = ConfigKeys.dependenciesAllowedEagleItemKey;
    final value = json[key];
    if (value != null && value is! bool) {
      throw InvalidConfigException('The "$key" value must be a boolean.');
    }
    return value as bool?;
  }

  List<String>? _readStringList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is! List || value.any((item) => item is! String)) {
      throw InvalidConfigException(
        'The "$key" value must be a list of strings.',
      );
    }
    return List<String>.from(value);
  }

  String _readFilePattern(Map<String, dynamic> json) {
    final key = ConfigKeys.filePatternEagleItemKey;
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw InvalidConfigException(
        'The "$key" value is required and must be a non-empty string.',
      );
    }
    return value;
  }

  String? _readName(Map<String, dynamic> json) {
    final key = ConfigKeys.nameEagleItemKey;
    final value = json[key];
    if (value != null && value is! String) {
      throw InvalidConfigException('The "$key" value must be a string.');
    }
    return value as String?;
  }
}
