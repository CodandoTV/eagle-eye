import 'package:todoapp/data/model/task.dart';

class TasksScreenCallbacks {
  final Function updateTasks;
  final Function(Task, bool) onCompleteTask;
  final Function(Task) onRemoveTask;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function() onShare;
  final Function() onSort;

  const TasksScreenCallbacks({
    required this.updateTasks,
    required this.onCompleteTask,
    required this.onRemoveTask,
    required this.onReorder,
    required this.onShare,
    required this.onSort,
  });
}
