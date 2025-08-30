import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/data/model/checklist.dart';
import 'package:todoapp/ui/l10n/app_localizations.dart';
import 'package:todoapp/ui/screens/checklists/checklists_screen_state.dart';
import 'package:todoapp/ui/screens/checklists/checklists_screen_text_values.dart';
import 'package:todoapp/ui/screens/checklists/checklists_viewmodel.dart';
import 'package:todoapp/ui/todo_app_router_config.gr.dart';
import 'package:todoapp/ui/widgets/checklist/checklists_list_widget.dart';
import 'package:todoapp/ui/widgets/confirmation_alert_dialog_widget.dart';
import 'package:todoapp/ui/widgets/custom_app_bar_widget.dart';
import 'package:todoapp/util/di/dependency_startup_handler.dart';
import 'package:todoapp/util/navigation_provider.dart';

@RoutePage()
class ChecklistsScreen extends StatelessWidget {
  const ChecklistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ChecklistsViewModel(
      GetItStartupHandlerWrapper.getIt.get(),
    );
    viewModel.updateChecklists();

    final checklistScreenTextValues = ChecklistsScreenTextValues(
      screenTitle: AppLocalizations.of(context)!.checklists,
      checklistAdded: AppLocalizations.of(context)!.checklist_added,
      removeChecklistDialogTitle:
          AppLocalizations.of(context)!.remove_checklist_dialog_title,
      removeChecklistDialogDesc:
          AppLocalizations.of(context)!.remove_checklist_dialog_desc,
      yes: AppLocalizations.of(context)!.yes,
      no: AppLocalizations.of(context)!.no,
      emptyChecklistMessage: AppLocalizations.of(context)!.empty_checklists,
    );

    return BlocProvider(
      create: (_) => viewModel,
      child: BlocBuilder<ChecklistsViewModel, ChecklistsScreenState>(
        builder: (context, uiState) => ChecklistsScaffold(
          uiState: uiState,
          checklistsScreenTextValues: checklistScreenTextValues,
          updateChecklists: viewModel.updateChecklists,
          onRemoveChecklist: viewModel.onRemoveChecklist,
          navigatorProvider: GetItStartupHandlerWrapper.getIt.get(),
        ),
      ),
    );
  }
}

class ChecklistsScaffold extends StatelessWidget {
  final ChecklistsScreenState uiState;
  final Function(Checklist) onRemoveChecklist;
  final Function updateChecklists;
  final NavigatorProvider navigatorProvider;
  final ChecklistsScreenTextValues checklistsScreenTextValues;

  const ChecklistsScaffold({
    super.key,
    required this.uiState,
    required this.checklistsScreenTextValues,
    required this.updateChecklists,
    required this.onRemoveChecklist,
    required this.navigatorProvider,
  });

  Widget _buildFloatingActionButton(Function() onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.plus_one),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWidget(
        title: checklistsScreenTextValues.screenTitle,
      ),
      floatingActionButton: _buildFloatingActionButton(
        () async {
          bool? result = await navigatorProvider.push(
            context,
            const ChecklistRoute(),
          );

          if (result == true) {
            updateChecklists();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.checklist_added,
                  ),
                ),
              );
            }
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: ChecklistsListWidget(
          checklists: uiState.checklists,
          emptyChecklistMessage:
              checklistsScreenTextValues.emptyChecklistMessage,
          onRemoveChecklist: (checklist) {
            _showConfirmationDialogToRemoveChecklist(context, checklist);
          },
          onSelectChecklist: (checklist) => navigatorProvider.push(
            context,
            TasksRoute(checklist: checklist),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialogToRemoveChecklist(
    BuildContext context,
    Checklist checklist,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ConfirmationAlertDialogWidget(
        title: checklistsScreenTextValues.removeChecklistDialogTitle,
        description: checklistsScreenTextValues.removeChecklistDialogDesc,
        secondaryButtonText: checklistsScreenTextValues.no,
        primaryButtonText: checklistsScreenTextValues.yes,
        onSecondaryButtonPressed: () => {
          navigatorProvider.onPop(context, null),
        },
        onPrimaryButtonPressed: () => {
          navigatorProvider.onPop(context, null),
          onRemoveChecklist(checklist)
        },
      ),
    );
  }
}
