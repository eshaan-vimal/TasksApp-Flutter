import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:frontend/models/task_model.dart';


class TaskLocalRepo 
{
  String tableName = 'tasks';
  Database? _database;


  Future<Database> get database async
  {
    try
    {
      _database ??= await _initDb();

      return _database!;
    }
    catch (error)
    {
      throw "Failed fetch local db";
    }
  }


  Future<Database> _initDb () async
  {
    try
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
                doneAt TEXT,
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
    catch (error)
    {
      throw "Failed to create local db";
    }
  }


  Future<void> insertTask (TaskModel task) async
  {
    try
    {
      final db = await database;

      await db.insert(
        tableName, 
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    catch (error)
    {
      throw "Failed to insert task to local db";
    }
  }


  Future<void> insertTasks (List<TaskModel> tasks) async
  {
    try
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
    catch (error)
    {
      throw "Failed to insert tasks to local db";
    }
  }


  Future<List<TaskModel>> getTasks () async
  {
    try
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
    catch (error)
    {
      throw "Failed to fetch tasks from local db";
    }
  }
  

  Future<void> updateTask (String taskId, DateTime doneAt) async
  {
    try 
    {
      final db = await database;

      await db.update(
        tableName,
        {
          'doneAt': doneAt.toIso8601String(),
          'pendingUpdate': 1,
        },
        where: 'id = ?', 
        whereArgs: [taskId],
      );

      print(db.query(tableName));
    } 
    catch (error) 
    {
      throw "Failed to mark task as completed";
    }
  }


  // Future<void> markUpdateTask (String taskId) async
  // {
  //   try
  //   {
  //     final db = await database;

  //     await db.update(
  //       tableName, 
  //       {'pendingUpdate': 1},
  //       where: 'id = ?',
  //       whereArgs: [taskId],
  //     );
  //   }
  //   catch (error)
  //   {
  //     throw "Failed to delete task (offline)";
  //   }
  // }


  Future<void> markDeleteTask (String taskId) async
  {
    try
    {
      final db = await database;

      await db.update(
        tableName, 
        {'pendingDelete': 1},
        where: 'id = ?',
        whereArgs: [taskId],
      );
    }
    catch (error)
    {
      throw "Failed to delete task (offline)";
    }
  }


  Future<void> deleteTask (String taskId) async
  {
    try
    {
      final db = await database;

      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [taskId],
      );
    }
    catch (error)
    {
      throw "Failed to delete task from local db";
    }
  }


  Future<List<TaskModel>> getRedundantTasks () async
  {
    try
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
    catch (error)
    {
      throw "Failed to fetch redundant tasks";
    }
  }


  Future<List<TaskModel>> getUnsyncedUpdatedTasks () async
  {
    try 
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
    catch (error)
    {
      throw "Failed to fetch locally updated tasks";
    }
  }


  Future<List<TaskModel>> getUnsyncedDeletedTasks () async
  {
    try
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
    catch (error)
    {
      throw "Failed to fetch locally deleted tasks";
    }
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
    try
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
    catch (error)
    {
      throw "Failed to update with remote task ID";
    }
  }


  Future<void> deleteTaskTable () async
  {
    try
    {
      final db = await database;

      await db.delete(tableName);
    }
    catch (error)
    {
      throw "Failed to delete local tasks table";
    }
  }
}