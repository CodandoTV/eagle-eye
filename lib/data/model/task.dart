import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

@freezed
class Task with _$Task {
  @override
  final int? id;
  @override
  final String title;
  @override
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
  });
}
