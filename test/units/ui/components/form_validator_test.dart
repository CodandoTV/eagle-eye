import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/ui/components/form_validator.dart';

void main() {
  test(
    'FormValidator -> give a null value when validate then returns false',
    () {
      // Arrange
      FormScreenValidator validator = FormScreenValidator();

      // Act
      final result = validator.validateValue(null);

      // Assert
      expect(result, false);
    },
  );

  test(
    'FormValidator -> give an empty value when validate then returns false',
    () {
      // Arrange
      FormScreenValidator validator = FormScreenValidator();

      // Act
      final result = validator.validateValue('');

      // Assert
      expect(result, false);
    },
  );

  test(
    'FormValidator -> give a valid value when validate then returns false',
    () {
      // Arrange
      FormScreenValidator validator = FormScreenValidator();

      // Act
      final result = validator.validateValue('Buy guinea pig food');

      // Assert
      expect(result, true);
    },
  );
}
