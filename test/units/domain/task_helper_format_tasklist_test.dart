import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/domain/tasks_helper.dart';

void main() {
  test(
    'formatTaskList -> test empty task list',
    () {
      // Arrange
      final taskHelper = TasksHelperImpl();

      // Act
      final result = taskHelper.formatTaskList(
        tasks: [],
      );

      // Assert
      expect(result, '');
    },
  );

  test(
    'formatTaskList -> test only not completed',
    () {
      // Arrange
      final taskHelper = TasksHelperImpl();

      // Act
      final result = taskHelper.formatTaskList(
        tasks: [
          const Task(
            id: null,
            title: 'Task A - Not completed',
            isCompleted: false,
          ),
          const Task(
            id: null,
            title: 'Task B - Not completed',
            isCompleted: false,
          ),
          const Task(
            id: null,
            title: 'Task C - Completed',
            isCompleted: true,
          ),
        ],
      );

      // Assert
      expect(
        result,
        '- Task A - Not completed\n'
        '- Task B - Not completed\n',
      );
    },
  );
}
