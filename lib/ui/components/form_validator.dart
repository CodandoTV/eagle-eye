import 'package:injectable/injectable.dart';

@injectable
class FormScreenValidator {
  bool validateValue(String? value) {
    final valueNoEmptySpaces = value?.trim();
    return valueNoEmptySpaces != null &&
        valueNoEmptySpaces.isNotEmpty;
  }
}
