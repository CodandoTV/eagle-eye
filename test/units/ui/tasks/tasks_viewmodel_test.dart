import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/domain/tasks_helper.dart';
import 'package:todoapp/ui/screens/tasks/tasks_screen_state.dart';
import 'package:todoapp/ui/screens/tasks/tasks_viewmodel.dart';

import '../../../fakes/fake_repository.dart';
import '../../../fakes/fake_share_message_handler.dart';

void main() {
  test(
    'TasksViewModel -> test initial state',
    () {
      // Arrange
      final repository = FakeRepository(
        tasks: [],
        checklists: [],
      );

      // Act
      final viewModel = TasksViewModel(
        repository: repository,
        checklistId: null,
        shareMessageHandler: FakeShareMessageHandler(),
        tasksHelper: TasksHelperImpl(),
      );

      // Assert
      expect(
        viewModel.state,
        const TasksScreenState(
          tasks: [],
          showShareIcon: false,
          isLoading: true,
          progress: 0,
        ),
      );
    },
  );

  test(
    'TasksViewModel -> test updateTasks',
    () async {
      // Arrange
      const task1 = Task(
        id: 1,
        title: 'Task 1',
        isCompleted: false,
      );
      final repository = FakeRepository(
        tasks: [task1],
        checklists: [],
      );
      final viewModel = TasksViewModel(
        repository: repository,
        checklistId: null,
        shareMessageHandler: FakeShareMessageHandler(),
        tasksHelper: TasksHelperImpl(),
      );

      // Act
      await viewModel.updateTasks();

      // Assert
      expect(
        viewModel.state,
        const TasksScreenState(
          tasks: [
            task1,
          ],
          showShareIcon: true,
          progress: 0,
          isLoading: false,
        ),
      );
    },
  );

  test(
    'TasksViewModel -> test onCompleteTask',
    () async {
      const task1 = Task(
        id: 1,
        title: 'Task 1',
        isCompleted: false,
      );
      // Arrange
      final repository = FakeRepository(
        tasks: [task1],
        checklists: [],
      );
      final viewModel = TasksViewModel(
        repository: repository,
        checklistId: null,
        tasksHelper: TasksHelperImpl(),
        shareMessageHandler: FakeShareMessageHandler(),
      );

      await viewModel.updateTasks();

      // Act
      await viewModel.onCompleteTask(
        task1,
        true,
      );

      // Assert
      const expectedTask = Task(
        id: 1,
        title: 'Task 1',
        isCompleted: true,
      );
      expect(
        viewModel.state,
        const TasksScreenState(
          tasks: [
            expectedTask,
          ],
          showShareIcon: false,
          progress: 1,
          isLoading: false,
        ),
      );
    },
  );

  test(
    'TasksViewModel -> test onRemoveTask',
    () async {
      const task1 = Task(
        id: 1,
        title: 'Task 1',
        isCompleted: false,
      );
      // Arrange
      final repository = FakeRepository(
        tasks: [task1],
        checklists: [],
      );
      final viewModel = TasksViewModel(
        repository: repository,
        checklistId: null,
        shareMessageHandler: FakeShareMessageHandler(),
        tasksHelper: TasksHelperImpl(),
      );

      await viewModel.updateTasks();

      // Act
      await viewModel.onRemoveTask(task1);

      // Assert
      expect(
        viewModel.state,
        const TasksScreenState(
          progress: 0,
          tasks: [],
          showShareIcon: false,
          isLoading: false,
        ),
      );
    },
  );

  test(
    'TasksViewModel -> test onSort',
    () async {
      const task1 = Task(
        id: 1,
        title: 'Task 1',
        isCompleted: true,
      );
      const task2 = Task(
        id: 2,
        title: 'Task 2',
        isCompleted: false,
      );

      // Arrange
      final repository = FakeRepository(
        tasks: [task1, task2],
        checklists: [],
      );
      final viewModel = TasksViewModel(
        repository: repository,
        checklistId: null,
        shareMessageHandler: FakeShareMessageHandler(),
        tasksHelper: TasksHelperImpl(),
      );

      await viewModel.updateTasks();

      // Act
      viewModel.onSort();

      // Assert
      expect(
        viewModel.state.tasks,
        [task2, task1],
      );
    },
  );
}
