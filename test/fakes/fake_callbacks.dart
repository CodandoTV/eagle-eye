import 'package:todoapp/ui/screens/tasks/tasks_screen_callbacks.dart';

class FakeCallbacks {
  static final emptyTasksScreenCallbacks = TasksScreenCallbacks(
    updateTasks: () => const {},
    onShare: () => const {},
    onCompleteTask: (_, __) => const {},
    onRemoveTask: (_) => const {},
    onReorder: (_, __) => const {},
    onSort: () {},
  );
}
