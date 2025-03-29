import 'dart:async';
import 'dart:convert';
import 'package:frontend/core/services/connectivity_service.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/models/task_model.dart';

class TaskRemoteRepo 
{
  Future<String> smartCompose ({
    required String token,
    required String title,
    required String description,
  }) async
  {
    try
    {
      if (await ConnectivityService().isOffline)
      {
        throw "Smart compose needs internet connectivity";
      }

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/task/compose'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      ).timeout(Duration(seconds: 10));

      if (res.statusCode != 200)
      {
        throw jsonDecode(res.body)['error'];
      }

      return jsonDecode(res.body)['description'];
    }
    on TimeoutException catch (_)
    {
      throw "Failed to connect to the server";
    }
    catch (error)
    {
      throw "Smart compose failed";
    }
  }


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
      if (await ConnectivityService().isOffline)
      {
        throw "Device offline";
      }

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

      return TaskModel.fromJson(res.body);
    }
    on TimeoutException catch (_)
    {
      throw "Failed to connect to the server";
    }
    catch (error)
    {
      throw "Failed to create new task";
    }
  }


  Future<List<TaskModel>> getTasks ({
    required String token,
  }) async
  {
    try
    {
      if (await ConnectivityService().isOffline)
      {
        throw "Device offline";
      }

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
    on TimeoutException catch (_)
    {
      throw "Failed to connect to the server";
    }
    catch (error)
    {
      throw "Failed to fetch tasks";
    }
  }


  Future<void> deleteTask ({
    required String token,
    required String taskId,
  }) async
  {
    try
    {
      if (await ConnectivityService().isOffline)
      {
        throw "Device offline";
      }

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
    on TimeoutException catch (_)
    {
      throw "Failed to connect to the server";
    }
    catch (error)
    {
      throw "Failed to delete task";
    }
  }


  Future<List<TaskModel>?> syncUpdatedTasks ({
    required String token,
    required List<TaskModel> updatedTasks,
  }) async
  {
    try
    {
      final updatedTasksMaps = [];
      for (final task in updatedTasks)
      {
        updatedTasksMaps.add(task.toMap());
      }

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/task/sync/update'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(updatedTasksMaps),
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


  Future<List<String>?> syncDeletedTasks ({
    required String token,
    required List<TaskModel> deletedTasks,
  }) async
  {
    try
    {
      final deletedTasksMaps = [];
      for (final task in deletedTasks)
      {
        deletedTasksMaps.add(task.toMap());
      }

      final res = await http.delete(
        Uri.parse('${Constants.backendUri}/task/sync/delete'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(deletedTasksMaps),
      );

      if (res.statusCode != 201)
      {
        return null;
      }
      
      final List<String> syncedTaskIds = jsonDecode(res.body).cast<String>();

      return syncedTaskIds;
    }
    catch (error)
    {
      return null;
    }
  }
}