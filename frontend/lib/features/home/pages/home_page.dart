import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:frontend/features/auth/cubits/auth_cubit.dart';
import 'package:frontend/features/home/cubits/task_cubit.dart';
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


  void deleteTask (String id) async
  {
    final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
    final taskCubit = context.read<TaskCubit>();

    await taskCubit.deleteTask(
      token: authCreds.user.token!, 
      taskId: id,
    );

    taskCubit.getTasks(token: authCreds.user.token!);
  }


  @override
  void initState ()
  {
    super.initState();

    final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
    final taskCubit = context.read<TaskCubit>();

    Connectivity().onConnectivityChanged.listen((data) async {
      if (data.contains(ConnectivityResult.wifi))
      {
        await taskCubit.syncTasks(authCreds.user.token!);
        taskCubit.getTasks(token: authCreds.user.token!);
      }
      else
      {
        taskCubit.getTasks(token: authCreds.user.token!);
      }
    });
  }

  @override
  Widget build (BuildContext context) 
  {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 25,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, NewTaskPage.route());
            }, 
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: BlocConsumer<TaskCubit,TaskState>(
          listener: (context, state) {

            if (state is TaskError)
            {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                )
              );
            }

            if (state is TaskDelete)
            {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Task deleted successfully!"),
                )
              );
            }

          },
          builder: (context, state) {

            if (state is TaskLoading)
            {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            else if (state is GetTasksSuccess)
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

                    Expanded(
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
                  SizedBox(height: 18,),
              
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
                                  onPressed: (_) => deleteTask(task.id),
                                  flex: 1,
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
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
                                  margin: EdgeInsets.only(left: 10, right: 5),
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    color: strengthenColour(task.colour, 0.7),
                                  ),
                                ),
                            
                                Text(
                                  DateFormat('hh:mm a').format(task.dueAt),
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(width: 10,),
                            
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

            return Text("Weird");

          }
        ),
      ),
    );
  }

}

