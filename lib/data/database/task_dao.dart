import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/data/database/checklist_dao.dart';
import 'package:todoapp/data/model/task.dart';

@LazySingleton()
class TaskDAO {
  static const tableName = 'Task';
  static const idKey = 'id';
  static const titleKey = 'title';
  static const descKey = 'desc';
  static const typeKey = 'type';
  static const isCompletedKey = 'isCompleted';
  static const positionKey = 'position';
  static const checklistKey = 'checklistKey';

  static const createTableQuery = 'CREATE TABLE ${TaskDAO.tableName} ('
      '${TaskDAO.idKey} INTEGER PRIMARY KEY, '
      '${TaskDAO.titleKey} TEXT, '
      '${TaskDAO.isCompletedKey} INTEGER, '
      '${TaskDAO.positionKey} INTEGER DEFAULT 0, '
      '${TaskDAO.checklistKey} INTEGER, '
      'FOREIGN KEY (${TaskDAO.checklistKey}) '
      'REFERENCES ${ChecklistDAO.tableName}(${ChecklistDAO.idKey}) '
      'ON DELETE CASCADE'
      ')';

  late Database _database;

  TaskDAO(Database database) {
    _database = database;
  }

  Future<List<Task>> getAll(int? checklistId) async {
    final result = await _database.query(
      tableName,
      orderBy: '$positionKey ASC',
      where: '${TaskDAO.checklistKey} = ?',
      whereArgs: [checklistId],
    );
    return result
        .map(
          (e) => Task(
            id: e[idKey] as int,
            title: e[titleKey] as String,
            isCompleted: (e[isCompletedKey] as int?) == 1,
          ),
        )
        .toList();
  }

  Map<String, dynamic> _taskToValues(Task task, int? checklistId) {
    return {
      idKey: task.id,
      titleKey: task.title,
      isCompletedKey: task.isCompleted ? 1 : 0,
      checklistKey: checklistId,
      positionKey: -1,
    };
  }

  Future<bool> update(Task task, bool isCompletedNewValue) async {
    final values = {isCompletedKey: isCompletedNewValue ? 1 : 0};

    final result = await _database.update(
      tableName,
      values,
      where: '$idKey = ${task.id}',
    );
    if (result == 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> delete(List<Task> tasks) async {
    final result = await _database.delete(
      tableName,
      where: '$idKey IN (${tasks.map((e) => e.id).join(',')})',
    );
    if (result == 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> add(Task task, int? checklistId) async {
    final result = await _database.insert(
      tableName,
      _taskToValues(task, checklistId),
    );
    if (result == 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> updateAll(List<Task> tasks) async {
    for (int i = 0; i < tasks.length; i++) {
      final values = {positionKey: i};
      await _database.update(tableName, values,
          where: '$idKey = ${tasks[i].id}');
    }
  }
}
