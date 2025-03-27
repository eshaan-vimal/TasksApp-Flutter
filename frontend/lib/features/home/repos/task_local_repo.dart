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
              pendingUpdate INTEGER NOT NULL,
              pendingDelete INTEGER NOT NULL
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
    
    final tasks = await db.query(
      tableName,
      where: 'pendingDelete = ?',
      whereArgs: [0],
    );
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


  Future<void> markDeleteTask (String taskId) async
  {
    final db = await database;

    await db.update(
      tableName, 
      {'pendingDelete': 1},
      where: 'id = ?',
      whereArgs: [taskId],
    );
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


  Future<List<TaskModel>> getRedundantTasks () async
  {
    final db = await database;

    final redundantTasks = await db.query(
      tableName,
      where: 'pendingUpdate = ? AND pendingDelete = ?',
      whereArgs: [1, 1],
    );

    List<TaskModel> redundantTasksList = [];

    for (final redundantTask in redundantTasks)
    {
      redundantTasksList.add(TaskModel.fromMap(redundantTask));
    }

    return redundantTasksList;
  }


  Future<List<TaskModel>> getUnsyncedUpdatedTasks () async
  {
    final db = await database;

    final updatedTasks = await db.query(
      tableName,
      where: 'pendingUpdate = ?',
      whereArgs: [1],
    );

    List<TaskModel> updatedTasksList = [];

    for (final updatedTask in updatedTasks)
    {
      updatedTasksList.add(TaskModel.fromMap(updatedTask));
    }

    return updatedTasksList;
  }


  Future<List<TaskModel>> getUnsyncedDeletedTasks () async
  {
    final db = await database;

    final deletedTasks = await db.query(
      tableName,
      where: 'pendingDelete = ?',
      whereArgs: [1],
    );

    List<TaskModel> deletedTasksList = [];

    for (final deletedTask in deletedTasks)
    {
      deletedTasksList.add(TaskModel.fromMap(deletedTask));
    }

    return deletedTasksList;
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