import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/data/database/checklist_dao.dart';
import 'package:todoapp/data/database/task_dao.dart';

const String dataBaseName = 'todo_data_base.db';

@module
abstract class DataBaseBuilder {
  @preResolve
  Future<Database> get database async {
    final path = join(await getDatabasesPath(), 'todogbm.db');
    Database dataBase = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          TaskDAO.createTableQuery,
        );

        await db.execute(
          ChecklistDAO.createTableQuery,
        );
      },
    );
    return dataBase;
  }
}
