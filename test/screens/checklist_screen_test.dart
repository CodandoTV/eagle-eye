import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/ui/components/form_validator.dart';
import 'package:todoapp/ui/screens/checklist/checklist_screen.dart';

import '../fakes/fake_navigator_provider.dart';
import '../fakes/fake_text_values.dart';
import '../utils/widgets_util.dart';

void main() {
  testWidgets(
    'ChecklistScreen - Insert a new checklist',
    (tester) async {
      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        child: ChecklistScreenScaffold(
          checklistScreenTextValues: FakeTextValues.checklistScreenTextValues,
          onAddNewChecklist: (_) => {},
          formScreenValidator: FormScreenValidator(),
          navigatorProvider: FakeNavigatorProvider(),
        ),
        tester: tester,
      );

      await tester.pumpWidget(widget);

      final floatActionButtonFinder = find.byType(FloatingActionButton);
      expect(floatActionButtonFinder, findsOneWidget);
    },
  );
}
