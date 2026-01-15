import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:test/test.dart';

void main() {
  test('no depends enabled - returns a valid configuration item object', () {
    final noDependsEnabled = {
      'filePattern': '*/data/model/*',
      'noDependsEnabled': true
    };

    final actual = EagleEyeConfigItem.fromJson(noDependsEnabled);
    expect(
      actual.noDependsEnabled,
      true,
    );
    expect(actual.filePattern, '*/data/model/*');
    expect(null, actual.doNotWithPatterns);
    expect(null, actual.justWithPatterns);
  });

  test('do not with - returns a valid configuration item object', () {
    final doNotWith = {
      'filePattern': '*viewmodel.dart',
      'doNotWithPatterns': ['*_screen.dart']
    };

    final actual = EagleEyeConfigItem.fromJson(doNotWith);

    expect(
      actual.doNotWithPatterns,
      ['*_screen.dart'],
    );
    expect(actual.noDependsEnabled, null);
    expect(actual.filePattern, '*viewmodel.dart');
    expect(actual.justWithPatterns, null);
  });

  test('just with - returns a valid configuration item object', () {
    final doNotWith = {
      'filePattern': '*screen.dart',
      'justWithPatterns': ['*_widget.dart']
    };

    final actual = EagleEyeConfigItem.fromJson(doNotWith);

    expect(actual.justWithPatterns, ['*_widget.dart']);
    expect(actual.doNotWithPatterns, null);
    expect(actual.noDependsEnabled, null);
    expect(actual.filePattern, '*screen.dart');
  });
}
