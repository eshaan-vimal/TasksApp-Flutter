part of 'task_cubit.dart';


sealed class TaskState 
{
    const TaskState ();
}


class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskComposing extends TaskState {}

class TaskComposeSuccess extends TaskState 
{
  final String description;
  const TaskComposeSuccess (this.description);
}

class NewTaskSuccess extends TaskState {}

class GetTasksSuccess extends TaskState 
{
    final List<TaskModel> tasksList;
    const GetTasksSuccess (this.tasksList);
}

class TaskDelete extends TaskState {}

class TaskError extends TaskState 
{
    final String error;
    const TaskError (this.error);
}