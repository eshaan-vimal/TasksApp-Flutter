import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:frontend/features/home/repos/task_remote_repo.dart';
import 'package:frontend/features/home/repos/task_local_repo.dart';
import 'package:frontend/models/task_model.dart';
import 'package:frontend/core/constants/utils.dart';

part 'task_state.dart';


class TaskCubit extends Cubit<TaskState>
{
  final taskRemoteRepo = TaskRemoteRepo();
  final taskLocalRepo = TaskLocalRepo();

  bool _isSyncing = false;

  TaskCubit () : super (TaskInitial());

  
  void newTask ({
    required String token,
    required String uid,
    required String title,
    required String description,
    required Color colour,
    required DateTime dueAt,
  }) async
  {
    try
    {
      emit(TaskLoading());

      final newTask = await taskRemoteRepo.newTask(
        token: token, 
        uid: uid,
        title: title, 
        description: description, 
        hexColour: rgbToHex(colour), 
        dueAt: dueAt
      );
      await taskLocalRepo.insertTask(newTask);

      emit(NewTaskSuccess());
    }
    catch (error)
    {
      try
      {
        final newTask = TaskModel(
          id: const Uuid().v4(),
          title: title,
          description: description,
          colour: colour,
          uid: uid,
          dueAt: dueAt,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          pendingUpdate: 1,
        );
        await taskLocalRepo.insertTask(newTask);

        emit(NewTaskSuccess());
      }
      catch (error)
      {
        emit(TaskError(error.toString()));
      }
    }
  }


  Future<void> getTasks ({
    required String token,
  }) async
  {
    try
    {
      emit(TaskLoading());

      final tasksList = await taskRemoteRepo.getTasks(token: token);
      await taskLocalRepo.insertTasks(tasksList);

      emit(GetTasksSuccess(tasksList));
    }
    catch (error)
    {
      try
      {
        final tasksList = await taskLocalRepo.getTasks();

        if (tasksList.isEmpty)
        {
          emit(TaskError("No tasks found"));
          return;
        }

        emit(GetTasksSuccess(tasksList));
      }
      catch (error)
      {
        emit(TaskError(error.toString()));
      }
    }
  }


  Future<void> deleteTask ({
    required String token,
    required String taskId,
  }) async
  {
    try
    {
      emit(TaskLoading());

      await taskRemoteRepo.deleteTask(
        token: token,
        taskId: taskId,
      );
      await taskLocalRepo.deleteTask(taskId);

      emit(TaskDelete());
    }
    catch (error)
    {
      try
      {
        await taskLocalRepo.markDeleteTask(taskId);

        emit(TaskDelete());
      }
      catch (error)
      {
        emit(TaskError(error.toString()));
      }
    }
  }


  Future<void> syncTasks ({
    required token
  }) async
  {
    try
    {
      if (_isSyncing)
      {
        return;
      }
      _isSyncing = true;

      final redundantTasks = await taskLocalRepo.getRedundantTasks();

      for (final redundantTask in redundantTasks)
      {
        await taskLocalRepo.deleteTask(redundantTask.id);
      }

      await syncDeletedTasks(token);
      await syncUpdatedTasks(token);

      print("Sync successful");
    }
    catch (error)
    {
      emit(TaskError(error.toString()));
    }
    finally
    {
      _isSyncing = false;
    }
  }


  Future<void> syncUpdatedTasks (String token) async
  {
    try
    {
      final updatedTasks = await taskLocalRepo.getUnsyncedUpdatedTasks();
      if (updatedTasks.isEmpty)
      {
        return;
      }

      final List<TaskModel>? syncedTasks = await taskRemoteRepo.syncUpdatedTasks(
        token: token, 
        updatedTasks: updatedTasks
      );

      if (syncedTasks == null || syncedTasks.length != updatedTasks.length)
      {
        emit(TaskError("Sync for updated tasks failed"));
        return;
      }

      for (int i = 0; i < syncedTasks.length; i++)
      {
        final localTask = updatedTasks[i];
        final remoteTask = syncedTasks[i];

        await taskLocalRepo.updateTaskId(
          oldId: localTask.id, 
          syncedTask: remoteTask,
        );
      }

      print("Sync update successful");
    }
    catch (error)
    {
      emit(TaskError(error.toString()));
    }
  }


  Future<void> syncDeletedTasks (String token) async
  {
    try
    {
      final deletedTasks = await taskLocalRepo.getUnsyncedDeletedTasks();

      if (deletedTasks.isEmpty)
      {
        return;
      }

      final List<String>? syncedTaskIds = await taskRemoteRepo.syncDeletedTasks(
        token: token, 
        deletedTasks: deletedTasks,
      );

      if (syncedTaskIds == null || syncedTaskIds.length != deletedTasks.length)
      {
        emit(TaskError("Sync for deleted tasks failed"));
        return;
      }

      for (String taskId in syncedTaskIds)
      {
        await taskLocalRepo.deleteTask(taskId);
      }

      print("Sync delete successful");
    }
    catch (error)
    {
      emit(TaskError(error.toString()));
    }
  }
}