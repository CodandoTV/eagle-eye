import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/ui/screens/tasks/tasks_screen_state.dart';

class FakeStates {
  static const fakeTasksEmptyState = TasksScreenState(
    tasks: [],
    isLoading: false,
    progress: 0,
    showShareIcon: false,
  );

  static const fakeTasks50PercentState = TasksScreenState(
    tasks: [
      Task(id: 1, title: 'task1', isCompleted: false),
      Task(id: 2, title: 'task2', isCompleted: true),
      Task(id: 3, title: 'task3', isCompleted: false),
      Task(id: 4, title: 'task4', isCompleted: true),
    ],
    isLoading: false,
    progress: 0.5,
    showShareIcon: true,
  );

  static const fakeTasks100PercentState = TasksScreenState(
    tasks: [
      Task(id: 2, title: 'task2', isCompleted: true),
      Task(id: 4, title: 'task4', isCompleted: true),
    ],
    isLoading: false,
    progress: 1,
    showShareIcon: false,
  );
}
