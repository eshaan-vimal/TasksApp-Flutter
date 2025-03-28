import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:frontend/features/auth/cubits/auth_cubit.dart';
import 'package:frontend/features/home/cubits/task_cubit.dart';
import 'package:frontend/core/services/connectivity_service.dart';
import 'package:frontend/features/auth/pages/login_page.dart';
import 'package:frontend/features/home/pages/new_task_page.dart';
import 'package:frontend/features/home/widgets/date_selector.dart';
import 'package:frontend/features/home/widgets/task_card.dart';
import 'package:frontend/core/constants/utils.dart';


class HomePage extends StatefulWidget
{
  const HomePage ({super.key});


  static MaterialPageRoute route () => MaterialPageRoute(builder: (context) => const HomePage());

  @override
  State<HomePage> createState () => _HomePageState();
}


class _HomePageState extends State<HomePage>
{
  DateTime selectedDate = DateTime.now();

  bool hasSynced = false;


  void handleLogout ()
  {
    context.read<AuthCubit>().logout();

    Navigator.of(context).pushAndRemoveUntil(LoginPage.route(), (_) => false);
  }


  void handleGetTasks ()
  {
    final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
    final taskCubit = context.read<TaskCubit>();

    ConnectivityService().isOnline.then((isOnline) async {
      if (isOnline)
      {
        await taskCubit.syncTasks(token: authCreds.user.token!);
        taskCubit.getTasks(token: authCreds.user.token!);
      } 
      else 
      {
        taskCubit.getTasks(token: authCreds.user.token!);
      }
    });
  }


  void handleDeleteTask (String id) async
  {
    final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
    final taskCubit = context.read<TaskCubit>();

    await taskCubit.deleteTask(
      token: authCreds.user.token!, 
      taskId: id,
    );

    await taskCubit.getTasks(token: authCreds.user.token!);
  }


  @override
  void initState ()
  {
    super.initState();

    handleGetTasks();
  }

  @override
  Widget build (BuildContext context) 
  {
    return Scaffold(
    
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 25,
            letterSpacing: 2,
          ),
        ),
        actions: [
    
          IconButton(
            onPressed: () {
              Navigator.of(context).push(NewTaskPage.route());
            }, 
            icon: const Icon(Icons.add),
          ),
    
          IconButton(
            onPressed: handleLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
    
        ],
      ),
    
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: BlocConsumer<TaskCubit,TaskState>(
          listener: (context, state) {
    
            if (state is TaskDelete)
            {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(
                    child: Text("Task deleted successfully!"),
                  ),
                )
              );
            }
    
            else if (state is TaskError)
            {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text(state.error),
                  ),
                )
              );
            }
    
          },
    
          builder: (context, state) {
    
            if (state is GetTasksSuccess)
            {
              final tasks = state.tasksList.where((task) => (
                DateFormat('d').format(task.dueAt) == DateFormat('d').format(selectedDate) &&
                task.dueAt.month == selectedDate.month &&
                task.dueAt.year == selectedDate.year
              )).toList()..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    
              if (tasks.isEmpty)
              {
                return Column(
                  children: [
    
                    DateSelector(
                      selectedDate: selectedDate,
                      onTap: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
    
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Add a new task",
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
    
                  ],
                );
              }
    
              return Column(
                children: [
              
                  DateSelector(
                    selectedDate: selectedDate,
                    onTap: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 18,),
              
                  Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                    
                        final task = tasks[index];
                    
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Slidable(
                            key: ValueKey(task),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(), 
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (_) => handleDeleteTask(task.id),
                                  flex: 1,
                                  backgroundColor: const Color.fromRGBO(255, 82, 82, 1),
                                  foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
                                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                  icon: Icons.delete,
                                  label: 'Delete'
                                ),
                              ]
                            ),
                          
                            child: Row(
                              children: [
                            
                                Expanded(
                                  child: TaskCard(
                                    title: task.title, 
                                    description: task.description, 
                                    colour: task.colour,
                                  ),
                                ),
                            
                                Container(
                                  margin: const EdgeInsets.only(left: 10, right: 5),
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                    color: strengthenColour(task.colour, 0.7),
                                  ),
                                ),
                            
                                Text(
                                  DateFormat('hh:mm a').format(task.dueAt),
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                            
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                  )
                ],
              );
            }

            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
    
            // return const Center(
            //   child: Text(
            //     "Spooky",
            //   ),
            // );
    
          }
        ),
      ),
    );
  }

}

