import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import 'package:frontend/features/auth/cubits/auth_cubit.dart';
import 'package:frontend/features/home/cubits/task_cubit.dart';
import 'package:frontend/features/home/pages/home_page.dart';


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
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();


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


  void newTask () async
  {
    if (formKey.currentState!.validate())
    {
      final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
      context.read<TaskCubit>().newTask(
        token: authCreds.user.token!, 
        uid: authCreds.user.id,
        title: titleController.text.trim(), 
        description: descriptionController.text.trim(), 
        colour: selectedColour, 
        dueAt: selectedDate,
      );
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
    super.dispose();
  }

  @override
  Widget build (BuildContext context)
  {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          'Add New Task',
          style: TextStyle(
            fontSize: 25,
            letterSpacing: 2,
          ),
        ),
      ),

      body: SafeArea(
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

            else if (state is NewTaskSuccess)
            {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("New task added successfully!"),
                )
              );

              Navigator.pushAndRemoveUntil(context, HomePage.route(), (_) => false);
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
                              margin: EdgeInsets.only(bottom: 10.0),
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 18, color: Theme.of(context).primaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    DateFormat('dd-MM-yyyy').format(selectedDate),
                                    style: TextStyle(
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
                              margin: EdgeInsets.only(bottom: 10.0),
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time_outlined, size: 18, color: Theme.of(context).primaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    DateFormat('hh:mm a').format(selectedDate),
                                    style: TextStyle(
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
                        controller: titleController,
                         validator: validateTitle,
                        decoration: InputDecoration(
                          hintText: 'Title',
                        ),
                      ),
                      const SizedBox(height: 10,),
                  
                      TextFormField(
                        controller: descriptionController,
                        validator: validateDescription,
                        decoration: InputDecoration(
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
                        onPressed: newTask, 
                        child: const Text(
                          'ADD TASK',
                          style: TextStyle(
                            color: Colors.white,
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

    );
  }
}