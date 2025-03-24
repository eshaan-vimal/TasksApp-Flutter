import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';

import 'package:frontend/features/home/repos/task_remote_repo.dart';
import 'package:frontend/features/home/repos/task_local_repo.dart';
import 'package:frontend/models/task_model.dart';

part 'task_state.dart';


class TaskCubit extends Cubit<TaskState>
{
  final taskRemoteRepo = TaskRemoteRepo();
  final taskLocalRepo = TaskLocalRepo();

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

      await taskRemoteRepo.newTask(
        token: token, 
        uid: uid,
        title: title, 
        description: description, 
        hexColour: rgbToHex(colour), 
        dueAt: dueAt
      );

      emit(NewTaskSuccess());
    }
    catch (error)
    {
      emit(TaskError(error.toString()));
    }
  }


  void getTasks ({
    required String token,
  }) async
  {
    try
    {
      emit(TaskLoading());

      final tasksList = await taskRemoteRepo.getTasks(token: token);

      emit(GetTasksSuccess(tasksList));
    }
    catch (error)
    {
      emit(TaskError(error.toString()));
    }
  }


  Future<void> syncTasks (String token) async
  {
    final unsyncedTasks = await taskLocalRepo.getUnsyncedTasks();
    print(unsyncedTasks);
    if (unsyncedTasks.isEmpty)
    {
      return;
    }

    bool isSynced = await taskRemoteRepo.syncTasks(
      token: token, 
      unsyncedTasks: unsyncedTasks
    );

    if (isSynced)
    {
      for (final task in unsyncedTasks)
      {
        await taskLocalRepo.updateSyncStatus(task.id, 1);
      }
      print("Synced nigga");
    }
  }
}