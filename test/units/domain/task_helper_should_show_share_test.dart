import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/domain/tasks_helper.dart';

void main() {
  test(
    'shouldShowShareButton -> test empty task list',
    () {
      // Arrange
      final taskHelper = TasksHelperImpl();

      // Act
      final result = taskHelper.shouldShowShareButton([]);

      // Assert
      expect(result, false);
    },
  );

  test(
    'shouldShowShareButton -> there is a task not completed',
    () {
      // Arrange
      final taskHelper = TasksHelperImpl();

      // Act
      final result = taskHelper.shouldShowShareButton(
        [
          const Task(
            id: null,
            title: 'Task A - Not completed',
            isCompleted: false,
          ),
          const Task(
            id: null,
            title: 'Task B - Completed',
            isCompleted: true,
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
        true,
      );
    },
  );

  test(
    'shouldShowShareButton -> there is none not completed task',
    () {
      // Arrange
      final taskHelper = TasksHelperImpl();

      // Act
      final result = taskHelper.shouldShowShareButton(
        [
          const Task(
            id: null,
            title: 'Task A -Completed',
            isCompleted: true,
          ),
          const Task(
            id: null,
            title: 'Task B - Completed',
            isCompleted: true,
          ),
        ],
      );

      // Assert
      expect(
        result,
        false,
      );
    },
  );
}
