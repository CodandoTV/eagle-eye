import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/domain/tasks_helper.dart';

void main() {
  test(
    'calculateProgress -> test empty task list',
        () {
      // Arrange
      final taskHelper = TasksHelperImpl();

      // Act
      final result = taskHelper.calculateProgress(
        tasks: [],
      );

      // Assert
      expect(result, 0.0);
    },
  );

  test(
    'calculateProgress -> test a positive progress',
        () {
      // Arrange
      final taskHelper = TasksHelperImpl();

      // Act
      final result = taskHelper.calculateProgress(
        tasks: [
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
        0.6666666666666666,
      );
    },
  );

  test(
    'calculateProgress -> test a bad progress',
        () {
      // Arrange
      final taskHelper = TasksHelperImpl();

      // Act
      final result = taskHelper.calculateProgress(
        tasks: [
          const Task(
            id: null,
            title: 'Task A - Not completed',
            isCompleted: false,
          ),
          const Task(
            id: null,
            title: 'Task B - Not Completed',
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
        0.3333333333333333,
      );
    },
  );

  test(
    'calculateProgress -> test a great progress',
        () {
      // Arrange
      final useCase = TasksHelperImpl();

      // Act
      final result = useCase.calculateProgress(
        tasks: [
          const Task(
            id: null,
            title: 'Task A - Completed',
            isCompleted: true,
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
        1.0,
      );
    },
  );

  test(
    'calculateProgress -> test a horrible progress',
        () {
      // Arrange
      final taskHelper = TasksHelperImpl();

      // Act
      final result = taskHelper.calculateProgress(
        tasks: [
          const Task(
            id: null,
            title: 'Task A - Not Completed',
            isCompleted: false,
          ),
          const Task(
            id: null,
            title: 'Task B - Not Completed',
            isCompleted: false,
          ),
          const Task(
            id: null,
            title: 'Task C - Not Completed',
            isCompleted: false,
          ),
        ],
      );

      // Assert
      expect(result, 0.0);
    },
  );
}