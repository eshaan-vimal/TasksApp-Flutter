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

class TaskSuggesting extends TaskState {}

class TaskSuggestSuccess extends TaskState
{
  final List<dynamic> suggestHints;
  final List<dynamic> suggestTasks;

  const TaskSuggestSuccess ({
    required this.suggestHints,
    required this.suggestTasks,
  });
}

class NewTaskSuccess extends TaskState {}

class GetTasksSuccess extends TaskState 
{
    final List<TaskModel> tasksList;
    const GetTasksSuccess (this.tasksList);
}

class TaskUpdate extends TaskState {}

class TaskDelete extends TaskState {}

class TaskError extends TaskState 
{
    final String error;
    const TaskError (this.error);
}