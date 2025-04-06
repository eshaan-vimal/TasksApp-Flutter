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
import 'package:frontend/models/task_model.dart';


class HomePage extends StatefulWidget
{
  const HomePage ({super.key});


  static MaterialPageRoute route () => MaterialPageRoute(builder: (context) => const HomePage());

  @override
  State<HomePage> createState () => _HomePageState();
}


class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin
{
  DateTime selectedDate = DateTime.now();
  late TabController tabController;

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


  void handleTaskDone (String taskId) async
  {
    final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
    final taskCubit = context.read<TaskCubit>();

    await taskCubit.updateTask(
      token: authCreds.user.token!, 
      taskId: taskId,
      doneAt: DateTime.now(),
    );

    await taskCubit.getTasks(token: authCreds.user.token!);
  }


  void handleDeleteTask (String taskId) async
  {
    final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
    final taskCubit = context.read<TaskCubit>();

    await taskCubit.deleteTask(
      token: authCreds.user.token!, 
      taskId: taskId,
    );

    await taskCubit.getTasks(token: authCreds.user.token!);
  }


  @override
  void initState ()
  {
    super.initState();
    tabController = TabController(length: 3, vsync: this);

    handleGetTasks();
  }

  @override
  void dispose ()
  {
    tabController.dispose();

    super.dispose();
  }



  Widget tabView (List<TaskModel> tasks, int tab)
  {
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final then = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (tasks.isEmpty)
    {
      return Center(
        child: Text(
          tab == 1 ?
          (now.isBefore(then) || now == then ? 
          "Add a new task" : "None pending") :
          tab == 2 ?
          "None completed" :
          "None missed",
          style: const TextStyle(
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
    
        final task = tasks[index];
    
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Slidable(
            key: ValueKey(task),
            startActionPane: ActionPane(
              motion: const ScrollMotion(), 
              extentRatio: 0.15,
              children: [
                CustomSlidableAction(
                  onPressed: (_) {
                    if (tab == 1 && DateTime.now().isBefore(task.dueAt))
                    {
                      handleTaskDone(task.id);
                    }
                  },
                  flex: 1,
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  child: tab == 1 ? 
                  const Icon(
                    Icons.check_box_outline_blank_rounded,
                    size: 20,
                  ) :
                  tab == 2 ?
                  const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.check_box_outline_blank_rounded,
                        size: 20,
                      ),
                      Icon(
                        Icons.check_rounded,
                        weight: 5,
                        color: Color(0xFF00FF9C),
                        size: 24,
                      ),
                    ],
                  ) :
                  const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.check_box_outline_blank_rounded,
                        size: 20,
                      ),
                      Icon(
                        Icons.close_rounded,
                        weight: 5,
                        color: Color.fromRGBO(244, 67, 54, 1),
                        size: 21,
                      ),
                    ],
                  )
                ),
              ]
            ),
            endActionPane: ActionPane(
              motion: const ScrollMotion(), 
              extentRatio: 0.25,
              children: [
                CustomSlidableAction(
                  onPressed: (_) => handleDeleteTask(task.id),
                  flex: 1,
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(244, 67, 54, 1),
                      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: Icon(
                      Icons.delete,
                      size: 30,
                    ),
                  ),
                ),
              ]
            ),
          
            child: Row(
              children: [
                
                Expanded(
                  child: TaskCard(
                    title: task.title, 
                    description: task.description, 
                    colour: task.colour
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Row(
                      children: [

                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 5),
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            color: tab == 3 ?
                            const Color.fromRGBO(244, 67, 54, 1) :
                            strengthenColour(task.colour, 0.7),
                          ),
                        ),
                    
                        Text(
                          DateFormat('hh:mm a').format(task.dueAt),
                          style: TextStyle(
                            color: tab == 3 ?
                            const Color.fromRGBO(244, 67, 54, 1) : null,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),

                      ],
                    ),

                    tab == 2 ?
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 5),
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            color: const Color.fromRGBO(76, 175, 80, 1)
                          ),
                        ),
                    
                        Text(
                          DateFormat('dd|MM|yyyy').format(task.dueAt) != DateFormat('dd|MM|yyyy').format(task.doneAt!) ?
                          DateFormat('dd|MM|yyyy').format(task.doneAt!) :
                          DateFormat('hh:mm a').format(task.doneAt!),
                          style: TextStyle(
                            color: const Color.fromRGBO(76, 175, 80, 1),
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ) :
                    const SizedBox(),

                  ],
                ),
            
              ],
            ),
          ),
        );
      }
    );
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

            if (state is TaskUpdate)
            {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(
                    child: Text("Task marked completed!"),
                  ),
                )
              );
            }
    
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
              List<TaskModel> pendingTasks = [];
              List<TaskModel> doneTasks = [];
              List<TaskModel> missedTasks = [];

              for (final task in state.tasksList)
              {
                if (
                  DateFormat('d').format(task.dueAt) == DateFormat('d').format(selectedDate) &&
                  task.dueAt.month == selectedDate.month &&
                  task.dueAt.year == selectedDate.year
                )
                {
                  if (DateTime.now().isBefore(task.dueAt) && task.doneAt == null)
                  {
                    pendingTasks.add(task);
                  }
                  else if (task.doneAt != null)
                  {
                    doneTasks.add(task);
                  }
                  else
                  {
                    missedTasks.add(task);
                  }
                }
              }

              pendingTasks.sort((a, b) => a.dueAt.compareTo(b.dueAt));
              doneTasks.sort((a, b) => a.dueAt.compareTo(b.dueAt));
              missedTasks.sort((a, b) => a.dueAt.compareTo(b.dueAt));

              // print("Pending $pendingTasks");
              // print("DONE $doneTasks");
              // print("MISSED $missedTasks");

              // final tasks = state.tasksList.where((task) => (
              //   DateFormat('d').format(task.dueAt) == DateFormat('d').format(selectedDate) &&
              //   task.dueAt.month == selectedDate.month &&
              //   task.dueAt.year == selectedDate.year
              // )).toList()..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    
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
                  const SizedBox(height: 15,),

                  TabBar(
                    controller: tabController,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.pending_rounded),
                        text: 'Pending',
                      ),
                      Tab(
                        icon: const Icon(Icons.done_rounded),
                        text: 'Completed',
                      ),
                      Tab(
                        icon: const Icon(Icons.error_rounded),
                        text: 'Missed',
                      ),
                    ],
                  ),
                  const SizedBox(height: 15,),

                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        tabView(pendingTasks, 1),
                        tabView(doneTasks, 2),
                        tabView(missedTasks, 3),
                      ]
                    ),
                  ),
              
                ],
              );
            }

            print(state);

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

