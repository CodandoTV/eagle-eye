import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist_screen_text_values.freezed.dart';

@freezed
class ChecklistScreenTextValues with _$ChecklistScreenTextValues {
  @override
  final String screenTitle;
  @override
  final String checklistLabel;
  @override
  final String checklistErrorMessage;

  const ChecklistScreenTextValues({
    required this.screenTitle,
    required this.checklistLabel,
    required this.checklistErrorMessage,
  });
}
