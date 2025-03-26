import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:frontend/models/task_model.dart';


class TaskLocalRepo 
{
  String tableName = 'tasks';
  Database? _database;


  Future<Database> get database async
  {
    _database ??= await _initDb();

    return _database!;
  }


  Future<Database> _initDb () async
  {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
            CREATE TABLE $tableName(
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT NOT NULL,
              hexColour TEXT NOT NULL,
              uid TEXT NOT NULL,
              dueAt TEXT NOT NULL,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL,
              isSynced INTEGER NOT NULL
            )
          '''
        );
      }
    );
  }


  Future<void> insertTask (TaskModel task) async
  {
    final db = await database;

    await db.insert(
      tableName, 
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<void> insertTasks (List<TaskModel> tasks) async
  {
    final db = await database;

    final batch = db.batch();
    for (final task in tasks)
    {
      batch.insert(
        tableName, 
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }


  Future<List<TaskModel>> getTasks () async
  {
    final db = await database;

    final tasks = await db.query(tableName);
    List<TaskModel> tasksList = [];

    if (tasks.isNotEmpty)
    {
      for (final task in tasks)
      {
        tasksList.add(TaskModel.fromMap(task));
      }
    }

    return tasksList;
  }


  Future<void> deleteTask (String taskId) async
  {
    final db = await database;

    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }


  Future<List<TaskModel>> getUnsyncedTasks () async
  {
    final db = await database;

    final unsyncedTasks = await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    List<TaskModel> unsyncedTasksList = [];

    for (final unsyncedTask in unsyncedTasks)
    {
      unsyncedTasksList.add(TaskModel.fromMap(unsyncedTask));
    }

    return unsyncedTasksList;
  }


  // Future<void> updateSyncStatus (String id, int status) async
  // {
  //   final db = await database;

  //   await db.update(
  //     tableName, 
  //     {'isSynced': status},
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }


  Future<void> updateTaskId({
    required String oldId,
    required TaskModel syncedTask,
  }) async 
  {
    final db = await database;
    
    await db.transaction((txn) async {
      await txn.delete(
        tableName, 
        where: 'id = ?', 
        whereArgs: [oldId],
      );
      await txn.insert(
        tableName, 
        syncedTask.toMap(),
      );
    });
  }


  Future<void> deleteTaskTable () async
  {
    final db = await database;

    await db.delete(tableName);
  }
}