import 'package:eagle_eye/model/error_info.dart';
import 'package:eagle_eye/model/software_unit.dart';

abstract class ArchitectureRuleChecker {
  ErrorInfo? check({required SoftwareUnit softwareUnit});
}
