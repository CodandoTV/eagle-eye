
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_screen_text_values.freezed.dart';

@freezed
class TaskScreenTextValues with _$TaskScreenTextValues {
  @override
  final String taskLabel;
  @override
  final String taskErrorMessage;

  const TaskScreenTextValues({
    required this.taskErrorMessage,
    required this.taskLabel,
  });
}
