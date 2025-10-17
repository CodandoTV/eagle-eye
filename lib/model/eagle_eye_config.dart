import 'package:eagle_eye/model/eagle_eye_config_item.dart';

/// Represents the full Eagle Eye configuration.
///
/// The [EagleEyeConfig] contains a list of [EagleEyeConfigItem]s,
/// each defining dependency rules for specific files or file patterns.
/// This class acts as the top-level model for the Eagle Eye configuration
/// system used to enforce architectural constraints.
class EagleEyeConfig {
  /// The list of configuration items defining rules for different files.
  List<EagleEyeConfigItem> items;

  /// Creates a new [EagleEyeConfig] with the given list of [items].
  EagleEyeConfig({required this.items});
}
