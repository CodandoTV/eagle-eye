import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/ui/screens/startup/startup_screen.dart';

import '../utils/widgets_util.dart';

void main() {
  testWidgets(
    'StartupScreen - Loading state',
    (tester) async {
      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        child: const StartupContainer(
          isLoading: true,
        ),
        tester: tester,
      );

      await tester.pumpWidget(widget);

      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );
    },
  );
}
