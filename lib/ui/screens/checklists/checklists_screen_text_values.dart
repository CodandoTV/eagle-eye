

import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklists_screen_text_values.freezed.dart';

@freezed
class ChecklistsScreenTextValues with _$ChecklistsScreenTextValues {
  @override
  final String screenTitle;
  @override
  final String checklistAdded;
  @override
  final String removeChecklistDialogTitle;
  @override
  final String removeChecklistDialogDesc;
  @override
  final String yes;
  @override
  final String no;
  @override
  final String emptyChecklistMessage;

  const ChecklistsScreenTextValues({
    required this.screenTitle,
    required this.checklistAdded,
    required this.removeChecklistDialogTitle,
    required this.removeChecklistDialogDesc,
    required this.yes,
    required this.no,
    required this.emptyChecklistMessage,
  });
}
