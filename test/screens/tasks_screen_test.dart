import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/ui/screens/tasks/tasks_screen.dart';
import 'package:todoapp/ui/widgets/progress_widget.dart';

import '../fakes/fake_callbacks.dart';
import '../fakes/fake_navigator_provider.dart';
import '../fakes/fake_states.dart';
import '../fakes/fake_text_values.dart';
import '../utils/widgets_util.dart';

void main() {
  testWidgets(
    'TasksScreen - Empty state message should appear if there is no task',
    (tester) async {
      const emptyMessage = 'No Tasks available';

      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        child: TasksScaffold(
          navigatorProvider: FakeNavigatorProvider(),
          uiState: FakeStates.fakeTasksEmptyState,
          checklistId: 1,
          checklistName: 'Pets',
          tasksScreenTextValues: FakeTextValues.tasksScreenTextValues.copyWith(
            emptyTasksMessage: emptyMessage,
          ),
          callbacks: FakeCallbacks.emptyTasksScreenCallbacks,
        ),
        tester: tester,
      );

      await tester.pumpWidget(widget);

      expect(find.text(emptyMessage), findsOneWidget);
    },
  );

  testWidgets(
    'TasksScreen - Progress bar should be blue if it is not 100% completed',
    (tester) async {
      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        child: TasksScaffold(
          navigatorProvider: FakeNavigatorProvider(),
          uiState: FakeStates.fakeTasks50PercentState,
          callbacks: FakeCallbacks.emptyTasksScreenCallbacks,
          checklistId: 1,
          checklistName: 'Pets',
          tasksScreenTextValues: FakeTextValues.tasksScreenTextValues,
        ),
        tester: tester,
      );

      await tester.pumpWidget(widget);

      ProgressWidget? progressWidget = find
          .byType(ProgressWidget)
          .evaluate()
          .first
          .widget as ProgressWidget?;

      expect(progressWidget!.baseColor(), Colors.blueAccent);
    },
  );

  testWidgets(
    'TasksScreen - Progress bar should be green if it is 100% completed',
    (tester) async {
      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        child: TasksScaffold(
          navigatorProvider: FakeNavigatorProvider(),
          uiState: FakeStates.fakeTasks100PercentState,
          callbacks: FakeCallbacks.emptyTasksScreenCallbacks,
          checklistId: 1,
          checklistName: 'pets',
          tasksScreenTextValues: FakeTextValues.tasksScreenTextValues,
        ),
        tester: tester,
      );

      await tester.pumpWidget(widget);

      ProgressWidget? progressWidget = find
          .byType(ProgressWidget)
          .evaluate()
          .first
          .widget as ProgressWidget?;

      expect(progressWidget!.baseColor(), Colors.green);
    },
  );

  testWidgets(
    'TasksScreen - Share option should not appear if it is 100% completed',
    (tester) async {
      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        child: TasksScaffold(
          navigatorProvider: FakeNavigatorProvider(),
          uiState: FakeStates.fakeTasks100PercentState,
          callbacks: FakeCallbacks.emptyTasksScreenCallbacks,
          checklistId: 1,
          checklistName: 'pets',
          tasksScreenTextValues: FakeTextValues.tasksScreenTextValues,
        ),
        tester: tester,
      );

      await tester.pumpWidget(widget);

      expect(find.byKey(const ValueKey(shareOptionKey)), findsNothing);
    },
  );

  testWidgets(
    'TasksScreen - Share option should appear if it is 50% completed',
    (tester) async {
      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        child: TasksScaffold(
          navigatorProvider: FakeNavigatorProvider(),
          uiState: FakeStates.fakeTasks50PercentState,
          callbacks: FakeCallbacks.emptyTasksScreenCallbacks,
          checklistId: 1,
          checklistName: 'pets',
          tasksScreenTextValues: FakeTextValues.tasksScreenTextValues,
        ),
        tester: tester,
      );

      await tester.pumpWidget(widget);

      expect(find.byKey(const ValueKey(shareOptionKey)), findsOneWidget);
    },
  );
}
