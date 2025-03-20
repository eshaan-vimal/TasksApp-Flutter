import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/pages/login_page.dart';
import 'package:frontend/features/home/pages/home_page.dart';


void main ()
{
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
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

        inputDecorationTheme: InputDecorationTheme(

          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 2.5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 2.5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),

          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              // color: Colors.grey.shade300,
              width: 3,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),

        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.black87),
            minimumSize: WidgetStateProperty.all(Size(double.infinity, 60)),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            )),
          ),
        ),

      ),
      home: BlocConsumer<AuthCubit,AuthState>(

        listener: (context, state) {
          if (state is AuthError)
          {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              )
            );
          }
        },

        builder: (context, state) {
          if (state is AuthLoggedIn)
          {
            return const HomePage();
          }
          else
          {
            return const LoginPage();
          }
        }

      ),
      debugShowCheckedModeBanner: false,
    );
  }
}