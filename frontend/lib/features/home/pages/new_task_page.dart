import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'dart:async';

import 'package:frontend/features/auth/cubits/auth_cubit.dart';
import 'package:frontend/features/home/cubits/task_cubit.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:frontend/core/services/connectivity_service.dart';


class NewTaskPage extends StatefulWidget
{
  const NewTaskPage ({super.key});


  static MaterialPageRoute route () => MaterialPageRoute(builder: (context) => const NewTaskPage());

  @override
  State<NewTaskPage> createState () => _NewTaskPageState();
}


class _NewTaskPageState extends State<NewTaskPage>
{
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Color selectedColour = Colors.purpleAccent;

  final formKey = GlobalKey<FormState>();
  final titleKey = GlobalKey<FormFieldState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isTyping = false;
  Timer? typingTimer;


  String? validateTitle (String? value)
  {
    if (value == null || value.trim().isEmpty)
    {
      return "Field empty";
    }

    return null;
  }

  String? validateDescription (String? value)
  {
    if (value == null || value.trim().isEmpty)
    {
      return "Field empty";
    }

    return null;
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


  void startTypingAnimation (String text)
  {
    int index = 0;
    isTyping = true;
    descriptionController.text = "";

    typingTimer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (index < text.length) 
      {
        descriptionController.text += text[index];
        // descriptionController.selection = TextSelection.fromPosition(
        //   TextPosition(offset: descriptionController.text.length),
        // );
        index++;
      } 
      else 
      {
        timer.cancel();
        setState(() {
          isTyping = false;
        });
      }
    });
  }

  void handleSmartCompose ()
  {
    if (titleKey.currentState!.validate())
    {
      final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
      final taskCubit = context.read<TaskCubit>();

      taskCubit.smartCompose(
        token: authCreds.user.token!, 
        title: titleController.text.trim(), 
        description: descriptionController.text.trim(),
      );
    }
  }

  void handleNewTask () async
  {
    if (formKey.currentState!.validate())
    {
      final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
      final taskCubit = context.read<TaskCubit>();

      taskCubit.newTask(
        token: authCreds.user.token!, 
        uid: authCreds.user.id,
        title: titleController.text.trim(), 
        description: descriptionController.text.trim(), 
        colour: selectedColour, 
        dueAt: selectedDate,
      );

      await taskCubit.getTasks(token: authCreds.user.token!);
    }
  }


  @override
  void initState ()
  {
    super.initState();

  }

  @override
  void dispose ()
  {
    titleController.dispose();
    descriptionController.dispose();
    typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build (BuildContext context)
  {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        handleGetTasks();
      },
      child: Scaffold(
      
        appBar: AppBar(
          title: const Text(
            'Add New Task',
            style: TextStyle(
              fontSize: 25,
              letterSpacing: 2,
            ),
          ),
          actions: [
            BlocConsumer<TaskCubit,TaskState>(
      
              listener: (context, state) {
                if (state is TaskComposeSuccess)
                {
                  startTypingAnimation(state.description);
                }
              },
      
              builder: (context, state) {
      
                if (state is TaskComposing)
                {
                  return const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
      
                return IconButton(
                  icon: const Icon(Icons.auto_fix_high),
                  onPressed: isTyping ? null : handleSmartCompose,
                );
              }
            ),
          ],
        ),
      
        body: SafeArea(
          child: BlocConsumer<TaskCubit,TaskState>(
            listener: (context, state) {
      
              // if (state is TaskError)
              // {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(
              //       content: Center(
              //         child: Text(state.error),
              //       ),
              //     )
              //   );
              // }
      
              if (state is NewTaskSuccess)
              {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(
                      child: Text("New task added successfully!"),
                    ),
                  )
                );
      
                Navigator.of(context).pushAndRemoveUntil(HomePage.route(), (_) => false);
              }
      
            },
            builder: (context, state) {
      
              if (state is TaskLoading)
              {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
      
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
      
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
      
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context, 
                                  firstDate: DateTime.now(), 
                                  lastDate: DateTime.now().add(Duration(days: 90)),
                                );
                                setState(() {
                                  if (date != null)
                                  {
                                    selectedDate = date;
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10.0),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: const BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                      width: 1.2,
                                      color: Color.fromRGBO(224, 224, 224, 1),
                                    ),
                                    horizontal: BorderSide(
                                      width: 1.2,
                                      color: Color.fromRGBO(224, 224, 224, 1),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('dd-MM-yyyy').format(selectedDate),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
      
                            GestureDetector(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context, 
                                  initialTime: TimeOfDay.now(),
                                );
                                setState(() {
                                  if (time != null)
                                  {
                                    selectedDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10.0),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: const BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                      width: 1.2,
                                      color: Color.fromRGBO(224, 224, 224, 1),
                                    ),
                                    horizontal: BorderSide(
                                      width: 1.2,
                                      color: Color.fromRGBO(224, 224, 224, 1),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.access_time_outlined, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('hh:mm a').format(selectedDate),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
      
                          ],
                        ),
                              
                        TextFormField(
                          key: titleKey,
                          controller: titleController,
                           validator: validateTitle,
                          decoration: const InputDecoration(
                            hintText: 'Title',
                          ),
                        ),
                        const SizedBox(height: 10,),
                    
                        TextFormField(
                          controller: descriptionController,
                          validator: validateDescription,
                          readOnly: isTyping,
                          decoration: const InputDecoration(
                            hintText: 'Description',
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20,),
                    
                        ColorPicker(
                          heading: const Text(
                            "Select Colour",
                            style: TextStyle(
                              letterSpacing: 1.3,
                            ),
                          ),
                          subheading: const Text(
                            "Select Shade",
                            style: TextStyle(
                              letterSpacing: 1.3,
                            ),
                          ),
                          onColorChanged: (Color colour) {
                            setState(() {
                              selectedColour = colour;
                            });
                          },
                          pickersEnabled: const {
                            ColorPickerType.wheel: true,
                          },
                        ),
                        const SizedBox(height: 20,),
                    
                        ElevatedButton(
                          onPressed: handleNewTask, 
                          child: const Text(
                            'ADD TASK',
                            style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.867),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                              
                    
                      ],
                    ),
                  ),
                ),
              );
      
            }
          ),
        )
      
      ),
    );
  }
}