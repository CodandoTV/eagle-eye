import 'package:todoapp/ui/screens/checklist/checklist_screen_text_values.dart';
import 'package:todoapp/ui/screens/checklists/checklists_screen_text_values.dart';
import 'package:todoapp/ui/screens/task/task_screen_text_values.dart';
import 'package:todoapp/ui/screens/tasks/tasks_screen_text_values.dart';

class FakeTextValues {
  static const tasksScreenTextValues = TasksScreenTextValues(
    taskAdded: 'Task Added',
    removeTaskDialogTitle: 'Remove Task',
    removeTaskDialogDesc: 'Are you sure?',
    yes: 'yes',
    no: 'no',
    sortMessage: 'It is sorted',
    emptyTasksMessage: 'No tasks available',
  );

  static const taskScreenTextValues = TaskScreenTextValues(
    taskErrorMessage: 'Task name is required',
    taskLabel: 'Task',
  );

  static const checklistsScreenTextValues = ChecklistsScreenTextValues(
    screenTitle: 'checklists',
    checklistAdded: 'A new checklist has been added',
    removeChecklistDialogTitle: 'Are you sure you want to remove it?',
    removeChecklistDialogDesc: 'Remove this checklist',
    yes: 'yes',
    no: 'no',
    emptyChecklistMessage: 'You have no checklists',
  );

  static const checklistScreenTextValues = ChecklistScreenTextValues(
    screenTitle: 'Checklist',
    checklistLabel: 'Checklist',
    checklistErrorMessage: 'Checklist name is required',
  );
}
