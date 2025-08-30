import 'package:flutter/material.dart';
import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/ui/widgets/task/task_cell_widget.dart';

class TasksListWidget extends StatelessWidget {
  final List<Task> tasks;
  final String emptyTasksMessage;
  final Function(Task) onRemoveTask;
  final Function(Task p1, bool p2) onCompleteTask;
  final Function(int oldIndex, int newIndex) onReorder;

  const TasksListWidget({
    super.key,
    required this.tasks,
    required this.emptyTasksMessage,
    required this.onRemoveTask,
    required this.onCompleteTask,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return _buildTaskList(context);
  }

  Widget _buildTaskList(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          emptyTasksMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    } else {
      return ReorderableListView.builder(
        onReorder: onReorder,
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 120,
        ),
        itemBuilder: (context, index) => TaskCellWidget(
          key: ValueKey(tasks[index].id),
          task: tasks[index],
          onRemoveTask: onRemoveTask,
          onCheckChanged: (value) =>
              onCompleteTask(tasks[index], value ?? false),
        ),
        itemCount: tasks.length,
      );
    }
  }
}
