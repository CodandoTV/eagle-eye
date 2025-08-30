import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/data/todo_repository.dart';
import 'package:todoapp/domain/tasks_helper.dart';
import 'package:todoapp/ui/screens/tasks/tasks_screen_state.dart';
import 'package:todoapp/util/share_message_handler.dart';

class TasksViewModel extends Cubit<TasksScreenState> {
  late TodoRepository _repository;
  late ShareMessageHandler _shareMessageHandler;

  TasksHelper tasksHelper;

  late int? _checklistId;

  TasksViewModel({
    required TodoRepository repository,
    required ShareMessageHandler shareMessageHandler,
    required this.tasksHelper,
    int? checklistId,
  }) : super(
          const TasksScreenState(
            tasks: [],
            progress: 0,
            isLoading: true,
            showShareIcon: false,
          ),
        ) {
    _repository = repository;

    _shareMessageHandler = shareMessageHandler;

    _checklistId = checklistId;
  }

  void _onLoad() {
    emit(
      state.copyWith(isLoading: true),
    );
  }

  Future<void> updateTasks() async {
    _onLoad();

    var tasks = await _repository.getTasks(_checklistId);
    emit(
      state.copyWith(
        isLoading: false,
        tasks: tasks,
        showShareIcon: tasksHelper.shouldShowShareButton(tasks),
        progress: tasksHelper.calculateProgress(tasks: tasks),
      ),
    );
  }

  Future<void> shareTasks({required String checklistName}) async {
    final checklist = tasksHelper.formatTaskList(
      tasks: state.tasks,
    );

    await _shareMessageHandler.share(
      text: checklist,
      title: checklistName,
    );
  }

  Future<void> onCompleteTask(Task task, bool value) async {
    _onLoad();

    var result = await _repository.updateTask(
      task,
      value,
    );

    if (result == true) {
      List<Task> tasks = List.from(state.tasks);
      var index = state.tasks.indexWhere((item) => item.id == task.id);
      if (index != -1) {
        tasks[index] = tasks[index].copyWith(isCompleted: value);
        emit(
          state.copyWith(
            progress: tasksHelper.calculateProgress(tasks: tasks),
            showShareIcon: tasksHelper.shouldShowShareButton(tasks),
            isLoading: false,
            tasks: tasks,
          ),
        );
      }
    }
  }

  Future<void> onRemoveTask(Task task) async {
    _onLoad();

    var result = await _repository.deleteTasks([task]);

    if (result) {
      List<Task> tasks = List.from(state.tasks);
      tasks.remove(task);
      emit(
        state.copyWith(
            progress: tasksHelper.calculateProgress(tasks: tasks),
            showShareIcon: tasksHelper.shouldShowShareButton(tasks),
            isLoading: false,
            tasks: tasks),
      );
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    List<Task> tasks = List.from(state.tasks);
    var task = tasks.removeAt(oldIndex);

    // If moving down the list,
    // adjust newIndex to account for the removed item
    if (newIndex > oldIndex) {
      newIndex--;
    }

    tasks.insert(newIndex, task);

    emit(
      state.copyWith(
        isLoading: false,
        showShareIcon: tasksHelper.shouldShowShareButton(tasks),
        tasks: tasks,
      ),
    );

    _repository.updateAllTasks(tasks);
  }

  void onSort() {
    List<Task> tasksToBeSorted = tasksHelper.sortByCompletedStatus(
      state.tasks,
    );

    emit(
      state.copyWith(
        tasks: tasksToBeSorted,
      ),
    );

    _repository.updateAllTasks(tasksToBeSorted);
  }
}
