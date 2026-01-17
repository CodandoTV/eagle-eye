import 'package:eagle_eye/model/eagle_eye_config_item.dart';
import 'package:test/test.dart';

void main() {
  test('dependenciesAllowed - returns a valid configuration item object', () {
    final noDependsEnabled = {
      'filePattern': '*/data/model/*',
      'dependenciesAllowed': false
    };

    final actual = EagleEyeConfigItem.fromJson(noDependsEnabled);
    expect(
      actual.dependenciesAllowed,
      false,
    );
    expect(actual.filePattern, '*/data/model/*');
    expect(null, actual.forbiddenDependencies);
    expect(null, actual.exclusiveDependencies);
  });

  test('forbiddenDependencies - returns a valid configuration item object', () {
    final doNotWith = {
      'filePattern': '*viewmodel.dart',
      'forbiddenDependencies': ['*_screen.dart']
    };

    final actual = EagleEyeConfigItem.fromJson(doNotWith);

    expect(
      actual.forbiddenDependencies,
      ['*_screen.dart'],
    );
    expect(actual.dependenciesAllowed, null);
    expect(actual.filePattern, '*viewmodel.dart');
    expect(actual.exclusiveDependencies, null);
  });

  test('exclusiveDependencies - returns a valid configuration item object', () {
    final doNotWith = {
      'filePattern': '*screen.dart',
      'exclusiveDependencies': ['*_widget.dart']
    };

    final actual = EagleEyeConfigItem.fromJson(doNotWith);

    expect(actual.exclusiveDependencies, ['*_widget.dart']);
    expect(actual.forbiddenDependencies, null);
    expect(actual.dependenciesAllowed, null);
    expect(actual.filePattern, '*screen.dart');
  });
}
