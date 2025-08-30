import 'package:injectable/injectable.dart';
import 'package:todoapp/data/database/checklist_dao.dart';
import 'package:todoapp/data/database/task_dao.dart';
import 'package:todoapp/data/model/checklist.dart';
import 'package:todoapp/data/model/task.dart';

abstract class TodoRepository {
  Future<List<Task>> getTasks(int? checklistId);

  Future<bool> updateTask(Task task, bool isCompletedNewValue);

  Future<bool> addTask(Task task, int? checklistId);

  Future<bool> deleteTasks(List<Task> tasks);

  Future<void> updateAllTasks(List<Task> tasks);

  Future<bool> addChecklist(Checklist checklist);

  Future<bool> deleteChecklist(Checklist checklist);

  Future<List<Checklist>> getChecklists();
}

@Injectable(as: TodoRepository)
class TodoRepositoryImpl implements TodoRepository {
  final TaskDAO _todoDAO;
  final ChecklistDAO _checklistDAO;

  TodoRepositoryImpl(
    this._todoDAO,
    this._checklistDAO,
  );

  @override
  Future<List<Task>> getTasks(int? checklistId) async {
    return _todoDAO.getAll(checklistId);
  }

  @override
  Future<bool> updateTask(Task task, bool isCompletedNewValue) async {
    return _todoDAO.update(task, isCompletedNewValue);
  }

  @override
  Future<bool> addTask(Task task, int? checklistId) async {
    return _todoDAO.add(task, checklistId);
  }

  @override
  Future<bool> deleteTasks(List<Task> tasks) async {
    return _todoDAO.delete(tasks);
  }

  @override
  Future<void> updateAllTasks(List<Task> tasks) {
    return _todoDAO.updateAll(tasks);
  }

  @override
  Future<bool> addChecklist(Checklist checklist) {
    return _checklistDAO.add(checklist);
  }

  @override
  Future<bool> deleteChecklist(Checklist checklist) {
    return _checklistDAO.delete(checklist);
  }

  @override
  Future<List<Checklist>> getChecklists() {
    return _checklistDAO.getAll();
  }
}
