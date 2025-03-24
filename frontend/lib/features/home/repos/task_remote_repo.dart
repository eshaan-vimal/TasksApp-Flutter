import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/models/task_model.dart';
import 'package:frontend/features/home/repos/task_local_repo.dart';


class TaskRemoteRepo 
{
  final taskLocalRepo = TaskLocalRepo();


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
      await taskLocalRepo.insertTask(newTask);

      return newTask;
    }
    catch (error)
    {
      try
      {
        final newTask = TaskModel(
          id: const Uuid().v4(),
          title: title,
          description: description,
          colour: hexToRgb(hexColour),
          uid: uid,
          dueAt: dueAt,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: 0,
        );

        await taskLocalRepo.insertTask(newTask);
        return newTask;
      }
      catch (error)
      {
        rethrow;
      }
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

      await taskLocalRepo.insertTasks(tasksList);

      return tasksList;
    }
    catch (error)
    {
      final tasks = await taskLocalRepo.getTasks();

      if (tasks.isNotEmpty)
      {
        return tasks;
      }

      rethrow;
    }
  }


  Future<bool> syncTasks ({
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
        return false;
      }

    
      return true;
    }
    catch (error)
    {
      return false;
    }
  }
}