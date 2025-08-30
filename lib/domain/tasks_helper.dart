import 'package:injectable/injectable.dart';
import 'package:todoapp/data/model/task.dart';

abstract class TasksHelper {
  double calculateProgress({required List<Task> tasks});

  String formatTaskList({required List<Task> tasks});

  bool shouldShowShareButton(List<Task> tasks);

  List<Task> sortByCompletedStatus(List<Task> tasks);
}

@Injectable(as: TasksHelper)
class TasksHelperImpl implements TasksHelper {

  @override
  double calculateProgress({required List<Task> tasks}) {
    int completedTasks = 0;
    for (var task in tasks) {
      if (task.isCompleted) {
        completedTasks++;
      }
    }

    if (tasks.isNotEmpty) {
      return completedTasks / tasks.length.toDouble();
    } else {
      return 0.0;
    }
  }

  @override
  String formatTaskList({required List<Task> tasks}) {
    var checklist = '';

    for (var task in tasks) {
      if (task.isCompleted == false) {
        checklist += '- ${task.title}\n';
      }
    }
    return checklist;
  }

  @override
  bool shouldShowShareButton(List<Task> tasks) {
    return tasks.any((task) => task.isCompleted == false);
  }

  @override
  List<Task> sortByCompletedStatus(List<Task> tasks) {
    List<Task> tasksToBeSorted = List.from(tasks);
    tasksToBeSorted.sort((a, b) => _sort(a, b));
    return tasksToBeSorted;
  }

  int _sort(Task a, Task b) {
    if (a.isCompleted == false && b.isCompleted) {
      return -1;
    } else if (a.isCompleted && b.isCompleted == false) {
      return 1;
    } else {
      return 0;
    }
  }
}
