import 'package:flutter/material.dart';

import 'package:frontend/features/auth/pages/login_page.dart';


void main ()
{
  runApp(const MyApp ());
}

class MyApp extends StatelessWidget
{
  const MyApp ({super.key});

  
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
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}