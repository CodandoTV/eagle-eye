import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/data/database/task_dao.dart';
import 'package:todoapp/data/model/checklist.dart';

@LazySingleton()
class ChecklistDAO {
  static const tableName = 'Checklist';
  static const idKey = 'id';
  static const titleKey = 'title';

  static const createTableQuery = 'CREATE TABLE ${ChecklistDAO.tableName} ('
      '${ChecklistDAO.idKey} INTEGER PRIMARY KEY, '
      '${ChecklistDAO.titleKey} TEXT)';

  late Database _database;

  ChecklistDAO(Database database) {
    _database = database;
  }

  Future<List<Checklist>> getAll() async {
    final result = await _database.query(
      tableName,
    );
    return result
        .map(
          (e) => Checklist(
            id: e[idKey] as int,
            title: e[titleKey] as String,
          ),
        )
        .toList();
  }

  Map<String, dynamic> _checklistToValues(Checklist checklist) {
    return {
      idKey: checklist.id,
      titleKey: checklist.title,
    };
  }

  Future<bool> delete(Checklist checklist) async {
    final result = await _database.delete(
      tableName,
      where: '$idKey = ?',
      whereArgs: [checklist.id],
    );

    await _database.delete(
      TaskDAO.tableName,
      where: '${TaskDAO.checklistKey} = ?',
      whereArgs: [checklist.id],
    );

    if (result == 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> add(Checklist checklist) async {
    final result =
        await _database.insert(tableName, _checklistToValues(checklist));

    if (result == 1) {
      return true;
    } else {
      return false;
    }
  }
}
