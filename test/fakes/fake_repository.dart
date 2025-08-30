import 'package:todoapp/data/model/checklist.dart';
import 'package:todoapp/data/model/task.dart';
import 'package:todoapp/data/todo_repository.dart';

class FakeRepository implements TodoRepository {
  late List<Task> _tasks;
  late List<Checklist> _checklists;

  FakeRepository({
    required List<Task> tasks,
    required List<Checklist> checklists,
  }) {
    _tasks = tasks;
    _checklists = checklists;
  }

  @override
  Future<bool> addTask(Task task, checklistUuid) async {
    _tasks.add(task);
    return Future.value(true);
  }

  @override
  Future<bool> deleteTasks(List<Task> tasks) async {
    for (var task in tasks) {
      _tasks.remove(task);
    }
    return Future.value(true);
  }

  @override
  Future<List<Task>> getTasks(checklistUuid) async {
    return Future.value(_tasks);
  }

  @override
  Future<bool> updateTask(Task task, bool isCompletedNewValue) async {
    final index = _tasks.indexOf(task);
    if (index != -1) {
      _tasks[index] = task.copyWith(isCompleted: isCompletedNewValue);
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  Future<void> updateAllTasks(List<Task> tasks) async {
    _tasks = tasks;
  }

  @override
  Future<bool> addChecklist(Checklist checklist) async {
    _checklists.add(checklist);
    return Future.value(true);
  }

  @override
  Future<List<Checklist>> getChecklists() async {
    return Future.value(_checklists);
  }

  @override
  Future<bool> deleteChecklist(Checklist checklist) {
    return Future.value(true);
  }
}
