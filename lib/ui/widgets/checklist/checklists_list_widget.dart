import 'package:flutter/material.dart';
import 'package:todoapp/data/model/checklist.dart';
import 'package:todoapp/ui/widgets/checklist/checklist_item_widget.dart';

class ChecklistsListWidget extends StatelessWidget {
  final List<Checklist> checklists;
  final Function(Checklist) onRemoveChecklist;
  final Function(Checklist) onSelectChecklist;
  final String emptyChecklistMessage;

  const ChecklistsListWidget({
    super.key,
    required this.checklists,
    required this.emptyChecklistMessage,
    required this.onRemoveChecklist,
    required this.onSelectChecklist,
  });

  @override
  Widget build(BuildContext context) {
    return _buildTaskList(context);
  }

  Widget _buildTaskList(BuildContext context) {
    if (checklists.isEmpty) {
      return Center(
        child: Text(
          emptyChecklistMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 120),
        itemBuilder: (context, index) => ChecklistItemWidget(
            checklist: checklists[index],
            onRemoveChecklist: onRemoveChecklist,
            onSelectChecklist: onSelectChecklist,
        ),
        itemCount: checklists.length,
      );
    }
  }
}
