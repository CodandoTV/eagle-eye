import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/data/model/checklist.dart';
import 'package:todoapp/ui/screens/checklists/checklists_screen.dart';
import 'package:todoapp/ui/screens/checklists/checklists_screen_state.dart';
import 'package:todoapp/ui/widgets/checklist/checklists_list_widget.dart';

import '../fakes/fake_navigator_provider.dart';
import '../fakes/fake_text_values.dart';
import '../utils/widgets_util.dart';

void main() {
  testWidgets(
    'ChecklistsScreen - Empty message should appear if we have no checklists',
    (tester) async {
      const emptyChecklistMessage = 'You have no checklists';

      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        child: ChecklistsScaffold(
          uiState: const ChecklistsScreenState(
            checklists: [],
            isLoading: false,
          ),
          checklistsScreenTextValues: FakeTextValues.checklistsScreenTextValues,
          onRemoveChecklist: (_) => {},
          navigatorProvider: FakeNavigatorProvider(),
          updateChecklists: () => {},
        ),
        tester: tester,
      );

      await tester.pumpWidget(widget);

      find.text(emptyChecklistMessage);

      expect(find.text(emptyChecklistMessage), findsOneWidget);
    },
  );

  testWidgets(
    'ChecklistsScreen - Checklist widget should appear if we have checklists',
    (tester) async {
      final widget = WidgetsUtil.buildMaterialAppWidgetTest(
        child: ChecklistsScaffold(
          uiState: const ChecklistsScreenState(
            checklists: [
              Checklist(id: null, title: 'pets'),
              Checklist(id: null, title: 'supermarket'),
              Checklist(id: null, title: 'drugstore'),
              Checklist(id: null, title: 'street market'),
            ],
            isLoading: false,
          ),
          checklistsScreenTextValues: FakeTextValues.checklistsScreenTextValues,
          onRemoveChecklist: (_) => {},
          navigatorProvider: FakeNavigatorProvider(),
          updateChecklists: () => {},
        ),
        tester: tester,
      );

      await tester.pumpWidget(widget);

      expect(find.byType(ChecklistsListWidget), findsOneWidget);
    },
  );
}
