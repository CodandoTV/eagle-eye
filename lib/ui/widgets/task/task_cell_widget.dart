import 'package:flutter/material.dart';
import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/ui/widgets/task/task_title_widget.dart';

class TaskCellWidget extends StatelessWidget {
  static const checkboxKey = 'TaskCellWidget_Checkbox';

  final Task task;
  final Function(bool?) onCheckChanged;
  final Function(Task) onRemoveTask;

  const TaskCellWidget({
    super.key,
    required this.task,
    required this.onCheckChanged,
    required this.onRemoveTask,
  });

  @override
  Widget build(BuildContext context) {
    const cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );

    return Card(
      elevation: 4,
      shape: cardShape,
      child: ListTile(
        leading: IconButton(
          onPressed: () => {onRemoveTask(task)},
          icon: const Icon(Icons.close),
        ),
        title: TaskTitleWidget(
          taskTitle: task.title,
          isComplete: task.isCompleted,
        ),
        trailing: Checkbox(
          key: const Key(checkboxKey),
          value: task.isCompleted,
          onChanged: onCheckChanged,
        ),
      ),
    );
  }
}
