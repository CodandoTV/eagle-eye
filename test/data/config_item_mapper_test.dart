import 'package:eagle_eye/data/config_item_mapper.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigItemMapper', () {
    late ConfigItemMapper mapper;

    setUp(() {
      mapper = ConfigItemMapper();
    });

    test('dependenciesAllowed - returns a valid configuration item object', () {
      final noDependsEnabled = {
        'filePattern': '*/data/model/*',
        'dependenciesAllowed': false,
      };

      final actual = mapper.map(noDependsEnabled);
      expect(actual.dependenciesAllowed, false);
      expect(actual.filePattern, '*/data/model/*');
      expect(null, actual.forbiddenDependencies);
      expect(null, actual.exclusiveDependencies);
    });

    test(
      'forbiddenDependencies - returns a valid configuration item object',
      () {
        final doNotWith = {
          'filePattern': '*viewmodel.dart',
          'forbiddenDependencies': ['*_screen.dart'],
        };

        final actual = mapper.map(doNotWith);

        expect(actual.forbiddenDependencies, ['*_screen.dart']);
        expect(actual.dependenciesAllowed, null);
        expect(actual.filePattern, '*viewmodel.dart');
        expect(actual.exclusiveDependencies, null);
      },
    );

    test(
      'exclusiveDependencies - returns a valid configuration item object',
      () {
        final doNotWith = {
          'filePattern': '*screen.dart',
          'exclusiveDependencies': ['*_widget.dart'],
        };

        final actual = mapper.map(doNotWith);

        expect(actual.exclusiveDependencies, ['*_widget.dart']);
        expect(actual.forbiddenDependencies, null);
        expect(actual.dependenciesAllowed, null);
        expect(actual.filePattern, '*screen.dart');
      },
    );

    test('name - is optional and defaults to null when absent', () {
      final actual = mapper.map({'filePattern': '*screen.dart'});

      expect(actual.name, null);
    });

    test('name - maps a provided name', () {
      final actual = mapper.map({
        'filePattern': '*screen.dart',
        'name': 'screens-only-widgets',
      });

      expect(actual.name, 'screens-only-widgets');
    });
  });
}
