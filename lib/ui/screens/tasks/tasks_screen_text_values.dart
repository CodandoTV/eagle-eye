import 'package:freezed_annotation/freezed_annotation.dart';

part 'tasks_screen_text_values.freezed.dart';

@freezed
class TasksScreenTextValues with _$TasksScreenTextValues {
  @override
  final String removeTaskDialogTitle;
  @override
  final String removeTaskDialogDesc;
  @override
  final String yes;
  @override
  final String no;
  @override
  final String emptyTasksMessage;
  @override
  final String taskAdded;
  @override
  final String sortMessage;

  const TasksScreenTextValues({
    required this.taskAdded,
    required this.removeTaskDialogTitle,
    required this.removeTaskDialogDesc,
    required this.yes,
    required this.no,
    required this.emptyTasksMessage,
    required this.sortMessage,
  });
}
