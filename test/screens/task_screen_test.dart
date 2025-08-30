import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/ui/components/form_validator.dart';
import 'package:todoapp/ui/screens/task/task_screen.dart';

import '../fakes/fake_navigator_provider.dart';
import '../fakes/fake_text_values.dart';
import '../utils/widgets_util.dart';

void main() {
  testWidgets(
    'TaskScreen - Insert a new task',
    (tester) async {
      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        child: TaskScreenScaffold(
          navigatorProvider: FakeNavigatorProvider(),
          onAddNewTask: (_) => {},
          taskScreenTextValues: FakeTextValues.taskScreenTextValues,
          formScreenValidator: FormScreenValidator(),
        ),
        tester: tester,
      );

      await tester.pumpWidget(widget);

      expect(
        find.byType(FloatingActionButton),
        findsOneWidget,
      );
    },
  );
}
