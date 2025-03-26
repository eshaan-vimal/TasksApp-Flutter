import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/models/task_model.dart';

class TaskRemoteRepo 
{

  Future<TaskModel> newTask ({
    required String token,
    required String uid,
    required String title,
    required String description,
    required String hexColour,
    required DateTime dueAt,
  }) async
  {
    try
    {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/task'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'hexColour': hexColour,
          'dueAt': dueAt.toIso8601String(),
        }),
      ).timeout(Duration(seconds: 3));

      if (res.statusCode != 201)
      {
        throw jsonDecode(res.body)['error'];
      }

      final newTask = TaskModel.fromJson(res.body);

      return newTask;
    }
    catch (error)
    {
      rethrow;
    }
  }


  Future<List<TaskModel>> getTasks ({
    required String token,
  }) async
  {
    try
    {
      final res = await http.get(
        Uri.parse('${Constants.backendUri}/task'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      ).timeout(Duration(seconds: 3));

      if (res.statusCode != 200)
      {
        throw jsonDecode(res.body)['error'];
      }

      final allTasks = jsonDecode(res.body);
      List<TaskModel> tasksList = [];

      for (var task in allTasks)
      {
        tasksList.add(TaskModel.fromMap(task));
      }

      return tasksList;
    }
    catch (error)
    {
      rethrow;
    }
  }


  Future<void> deleteTask ({
    required String token,
    required String taskId,
  }) async
  {
    try
    {
      final res = await http.delete(
        Uri.parse('${Constants.backendUri}/task'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'taskId': taskId,
        }),
      ).timeout(Duration(seconds: 3));

      if (res.statusCode != 200)
      {
        throw jsonDecode(res.body)['error'];
      }
    }
    catch (error)
    {
      rethrow;
    }
  }


  Future<List<TaskModel>?> syncTasks ({
    required String token,
    required List<TaskModel> unsyncedTasks,
  }) async
  {
    try
    {
      final unsyncedTasksMaps = [];
      for (final task in unsyncedTasks)
      {
        unsyncedTasksMaps.add(task.toMap());
      }

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/task/sync'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(unsyncedTasksMaps),
      );

      if (res.statusCode != 201)
      {
        return null;
      }

      final List<dynamic> returnedTasks = jsonDecode(res.body);
      final syncedTasks = returnedTasks.map((syncedTask) => TaskModel.fromMap(syncedTask)).toList();

      return syncedTasks;
    }
    catch (error)
    {
      return null;
    }
  }
}