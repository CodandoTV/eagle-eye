import 'package:flutter/material.dart';

import 'package:todoapp/data/model/checklist.dart';

class ChecklistItemWidget extends StatelessWidget {
  final Checklist checklist;
  final Function(Checklist) onRemoveChecklist;
  final Function(Checklist) onSelectChecklist;

  const ChecklistItemWidget({
    super.key,
    required this.checklist,
    required this.onRemoveChecklist,
    required this.onSelectChecklist,
  });

  Widget _internalContent(
    BuildContext context,
    Checklist checklist,
  ) {
    return ListTile(
      leading: IconButton(
        onPressed: () => onRemoveChecklist(checklist),
        icon: const Icon(Icons.close),
      ),
      title: Text(
        checklist.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      color: Theme.of(context).colorScheme.surfaceBright,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => onSelectChecklist(checklist),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 16,
            bottom: 16,
          ),
          child: _internalContent(context, checklist),
        ),
      ),
    );
  }
}
