import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/data/model/checklist.dart';
import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/ui/l10n/app_localizations.dart';
import 'package:todoapp/ui/screens/tasks/tasks_screen_callbacks.dart';
import 'package:todoapp/ui/screens/tasks/tasks_screen_state.dart';
import 'package:todoapp/ui/screens/tasks/tasks_screen_text_values.dart';
import 'package:todoapp/ui/screens/tasks/tasks_viewmodel.dart';
import 'package:todoapp/ui/todo_app_router_config.gr.dart';
import 'package:todoapp/ui/widgets/confirmation_alert_dialog_widget.dart';
import 'package:todoapp/ui/widgets/custom_app_bar_widget.dart';
import 'package:todoapp/ui/widgets/progress_widget.dart';
import 'package:todoapp/ui/widgets/task/tasks_list_widget.dart';
import 'package:todoapp/util/di/dependency_startup_handler.dart';
import 'package:todoapp/util/navigation_provider.dart';

const shareOptionKey = 'shareOption';

@RoutePage()
class TasksScreen extends StatelessWidget {
  final Checklist checklist;

  const TasksScreen({
    super.key,
    required this.checklist,
  });

  @override
  Widget build(BuildContext context) {
    final getIt = GetItStartupHandlerWrapper.getIt;
    final viewModel = TasksViewModel(
      repository: getIt.get(),
      shareMessageHandler: getIt.get(),
      checklistId: checklist.id,
      tasksHelper: getIt.get(),
    );
    viewModel.updateTasks();

    final tasksScreenTextValues = TasksScreenTextValues(
      taskAdded: AppLocalizations.of(context)!.task_added,
      removeTaskDialogTitle:
          AppLocalizations.of(context)!.remove_task_dialog_title,
      removeTaskDialogDesc:
          AppLocalizations.of(context)!.remove_task_dialog_desc,
      yes: AppLocalizations.of(context)!.yes,
      no: AppLocalizations.of(context)!.no,
      emptyTasksMessage: AppLocalizations.of(context)!.empty_tasks,
      sortMessage: AppLocalizations.of(context)!.sort_message,
    );

    return BlocProvider(
      create: (_) => viewModel,
      child: BlocBuilder<TasksViewModel, TasksScreenState>(
        builder: (context, uiState) => TasksScaffold(
          navigatorProvider: getIt.get(),
          uiState: uiState,
          checklistId: checklist.id,
          checklistName: checklist.title,
          tasksScreenTextValues: tasksScreenTextValues,
          callbacks: TasksScreenCallbacks(
            onCompleteTask: viewModel.onCompleteTask,
            onRemoveTask: viewModel.onRemoveTask,
            updateTasks: viewModel.updateTasks,
            onReorder: viewModel.reorder,
            onSort: () => {viewModel.onSort()},
            onShare: () => {
              viewModel.shareTasks(checklistName: checklist.title),
            },
          ),
        ),
      ),
    );
  }
}

class TasksScaffold extends StatelessWidget {
  final TasksScreenState uiState;
  final int? checklistId;
  final String checklistName;
  final TasksScreenTextValues tasksScreenTextValues;
  final TasksScreenCallbacks callbacks;
  final NavigatorProvider navigatorProvider;

  const TasksScaffold({
    super.key,
    required this.uiState,
    required this.checklistId,
    required this.checklistName,
    required this.tasksScreenTextValues,
    required this.navigatorProvider,
    required this.callbacks,
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
        title: checklistName,
        actions: _buildTopBarActions(
          context: context,
          sortedMessage: tasksScreenTextValues.sortMessage,
          onShare: callbacks.onShare,
          showShareButton: uiState.showShareIcon,
          onSort: callbacks.onSort,
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(
        () async {
          bool? result = await navigatorProvider.push(
            context,
            TaskRoute(
              checklistId: checklistId,
            ),
          );
          if (result == true) {
            await callbacks.updateTasks();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    tasksScreenTextValues.taskAdded,
                  ),
                ),
              );
            }
          }
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
            ),
            child: TasksListWidget(
              tasks: uiState.tasks,
              emptyTasksMessage: tasksScreenTextValues.emptyTasksMessage,
              onReorder: callbacks.onReorder,
              onRemoveTask: (task) =>
                  _showConfirmationDialogToRemoveTask(context, task),
              onCompleteTask: callbacks.onCompleteTask,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: ProgressWidget(
              progress: uiState.progress,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialogToRemoveTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ConfirmationAlertDialogWidget(
        title: tasksScreenTextValues.removeTaskDialogTitle,
        description: tasksScreenTextValues.removeTaskDialogDesc,
        secondaryButtonText: tasksScreenTextValues.no,
        primaryButtonText: tasksScreenTextValues.yes,
        onSecondaryButtonPressed: () => {
          navigatorProvider.onPop(context, null),
        },
        onPrimaryButtonPressed: () => {
          navigatorProvider.onPop(context, null),
          callbacks.onRemoveTask(task),
        },
      ),
    );
  }

  List<Widget> _buildTopBarActions({
    required bool showShareButton,
    required String sortedMessage,
    required VoidCallback onShare,
    required VoidCallback onSort,
    required BuildContext context,
  }) {
    List<Widget> menuActions = [];

    if (showShareButton) {
      menuActions.add(
        IconButton(
          onPressed: onShare,
          icon: const Icon(Icons.share),
          key: const ValueKey(shareOptionKey),
        ),
      );
    }

    menuActions.add(
      IconButton(
        onPressed: () => {
          onSort(),
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                sortedMessage,
              ),
            ),
          ),
        },
        icon: const Icon(Icons.sort),
      ),
    );

    return menuActions;
  }
}
