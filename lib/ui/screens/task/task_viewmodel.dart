import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/data/todo_repository.dart';

class TaskViewModel {
  late TodoRepository _repository;
  late int? _checklistId;

  TaskViewModel(TodoRepository repository, int? checklistId) {
    _repository = repository;
    _checklistId = checklistId;
  }

  bool validateTaskName(String taskName) {
    return taskName.isNotEmpty;
  }

  Future<void> addTask({
    required String title,
  }) async {
    await _repository.addTask(
      Task(
        id: null,
        title: title,
        isCompleted: false,
      ),
      _checklistId,
    );
  }
}
