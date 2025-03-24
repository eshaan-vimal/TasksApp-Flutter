part of 'task_cubit.dart';


sealed class TaskState 
{
    const TaskState ();
}


class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class NewTaskSuccess extends TaskState {}

class GetTasksSuccess extends TaskState 
{
    final List<TaskModel> tasksList;
    const GetTasksSuccess (this.tasksList);
}

class TaskError extends TaskState 
{
    final String error;
    const TaskError (this.error);
}