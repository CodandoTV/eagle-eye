import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/ui/widgets/task/task_cell_widget.dart';

import '../utils/widgets_util.dart';

void main() {
  testWidgets(
    'TaskCellWidget has a title',
    (tester) async {
      const taskName = 'Task A';

      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        tester: tester,
        child: TaskCellWidget(
          task: const Task(
            id: null,
            title: taskName,
            isCompleted: false,
          ),
          onCheckChanged: (_) => {},
          onRemoveTask: (_) => {},
        ),
      );

      await tester.pumpWidget(widget);

      final taskNameFinder = find.text(taskName);
      expect(taskNameFinder, findsOneWidget);
    },
  );

  testWidgets(
    'TaskCellWidget is completed',
    (tester) async {
      // Arrange
      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        tester: tester,
        child: TaskCellWidget(
          task: const Task(
            id: null,
            title: 'Anything',
            isCompleted: true,
          ),
          onCheckChanged: (_) => {},
          onRemoveTask: (_) => {},
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      final checkboxFinder = find.byKey(const Key(TaskCellWidget.checkboxKey));
      final checkbox = tester.widget(checkboxFinder) as Checkbox;

      // Assert
      expect(checkbox.value, true);
    },
  );

  testWidgets(
    'TaskCellWidget is not completed',
    (tester) async {
      // Arrange
      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        tester: tester,
        child: TaskCellWidget(
          task: const Task(
            id: null,
            title: 'Anything',
            isCompleted: false,
          ),
          onCheckChanged: (_) => {},
          onRemoveTask: (_) => {},
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      final checkboxFinder = find.byKey(const Key(TaskCellWidget.checkboxKey));
      final checkbox = tester.widget(checkboxFinder) as Checkbox;

      // Assert
      expect(checkbox.value, false);
    },
  );
}
