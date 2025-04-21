import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/auth/cubits/auth_cubit.dart';
import 'package:frontend/features/home/cubits/task_cubit.dart';
import 'package:frontend/features/auth/pages/login_page.dart';
import 'package:frontend/core/services/connectivity_service.dart';
import 'package:frontend/core/services/notification_service.dart';


void main () async
{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => TaskCubit())
      ],
      child: const MyApp(),
    )
  );
}


class MyApp extends StatefulWidget
{
  const MyApp ({super.key});

  @override
  State<MyApp> createState () => _MyAppState ();
}

class _MyAppState extends State<MyApp>
{
  @override
  void initState ()
  {
    super.initState();
    ConnectivityService().init();
    context.read<AuthCubit>().getUser();
  }


  @override
  void dispose ()
  {
    super.dispose();
  }

  
  @override
  Widget build (BuildContext context)
  {
    return MaterialApp(
      title: "Tasks App",
      theme: ThemeData(

        fontFamily: "Lato",

        brightness: Brightness.dark,

        // primaryIconTheme: const IconThemeData(
        //   color: Color(0xFF00FF9C),
        // ),

        iconTheme: const IconThemeData(
          color: Color(0xFF00FF9C),
        ),

        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            iconColor: WidgetStatePropertyAll(Color(0xFF00FF9C)),
          )
        ),

        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: const Color.fromARGB(255, 255, 0, 127),
        ),

        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color.fromARGB(255, 255, 0, 127),
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          behavior: SnackBarBehavior.floating, 
          elevation: 6.0,  
        ),

        inputDecorationTheme: const InputDecorationTheme(

          floatingLabelStyle: TextStyle(
            color: Color(0xFF00FF9C),
          ),

          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(224, 224, 224, 1),
              width: 1.2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(224, 224, 224, 1),
              width: 1.2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),

          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF00FF9C),
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),

        ),

        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            // backgroundColor: WidgetStatePropertyAll(Color(0xFF00FF9C),),
            backgroundColor: WidgetStatePropertyAll(Color(0xFF1C1C22)),
            foregroundColor: WidgetStatePropertyAll(Color(0xFF00FF9C)),
            minimumSize: WidgetStatePropertyAll(Size(double.infinity, 60)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xFF00FF9C),
                width: 0.7,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            )),
            // shadowColor: WidgetStatePropertyAll(Color(0xFF00FF9C)),
          ),
        ),

        tabBarTheme: TabBarThemeData(
          indicatorColor: const Color.fromARGB(255, 255, 0, 127),
          labelColor: const Color.fromARGB(255, 255, 0, 127),
        ),

        datePickerTheme: DatePickerThemeData(

          dividerColor: const Color.fromRGBO(255, 255, 255, 0.702),

          confirmButtonStyle: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 255, 0, 127)),
          ),
          cancelButtonStyle: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 255, 0, 127)),
          ),

          inputDecorationTheme: InputDecorationTheme(
            helperStyle: TextStyle(
              color: const Color.fromRGBO(255, 255, 255, 1),
            ),
            hintStyle: TextStyle(
              color: const Color.fromRGBO(255, 255, 255, 1),
            ),
          ),
          
          todayBackgroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) 
            {
              return const Color.fromARGB(255, 255, 0, 127);
            }
            return const Color.fromRGBO(0, 0, 0, 0);
          }),
          todayForegroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 255, 255, 255)),

          dayBackgroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) 
            {
              return const Color.fromARGB(255, 255, 0, 127);
            }
            return const Color.fromRGBO(0, 0, 0, 0);
          }),
          dayForegroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const Color.fromARGB(255, 121, 121, 121); 
            }
            if (states.contains(WidgetState.selected)) {
              return const Color.fromRGBO(0, 0, 0, 1); // Selected date
            }
            return const Color.fromARGB(255, 255, 255, 255); // Default date color
          }),

        ),

        timePickerTheme: TimePickerThemeData(

          confirmButtonStyle: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 255, 0, 127)),
          ),
          cancelButtonStyle: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 255, 0, 127)),
          ),

          dialHandColor: const Color(0xFF00FF9C),
          dialTextColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected))
            {
              return const Color.fromARGB(255, 0, 0, 0);
            }
            return const Color.fromARGB(255, 255, 255, 255);
          }),

          dayPeriodColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color.fromARGB(190, 255, 0, 128);
            }
            return const Color.fromRGBO(0, 0, 0, 0);
          }),

          hourMinuteColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color.fromARGB(255, 255, 0, 127);
            }
            return const Color.fromRGBO(66, 66, 66, 1);
          }),

        ),

        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStatePropertyAll(const Color.fromRGBO(255, 255, 255, 1)),
        )

      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}