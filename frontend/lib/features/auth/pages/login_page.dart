import 'package:flutter/material.dart';

import 'package:frontend/features/auth/pages/signup_page.dart';



class LoginPage extends StatefulWidget
{
  const LoginPage ({super.key});


  static MaterialPageRoute route () => MaterialPageRoute(builder: (context) => const LoginPage());

  @override
  State<LoginPage> createState () => _LoginPageState();
}


class _LoginPageState extends State<LoginPage>
{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  String? validateEmail (String? value)
  {
    if (value == null || value.trim().isEmpty)
    {
      return "Field empty";
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value))
    {
      return "Invalid email";
    }

    return null;
  }

  String? validatePassword (String? value)
  {
    if (value == null || value.trim().isEmpty)
    {
      return "Field empty";
    }
    if (value.length < 8)
    {
      return "Aleast 8 characters long";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) 
    {
      return 'Atleast one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) 
    {
      return 'Atleast one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) 
    {
      return 'Atleast one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) 
    {
      return 'Atleast one special character';
    }

    return null;
  }


  void loginUser ()
  {
    if (formKey.currentState!.validate())
    {
      //
    }
  }


  @override
  void dispose ()
  {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build (BuildContext context)
  {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          
              const Spacer(flex: 12,),
              Text(
                "Log In.",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(flex: 2,),
          
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter email",
                ),
                validator: validateEmail,
              ),
              const Spacer(flex: 1,),
          
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: "Enter password",
                ),
                validator: validatePassword,
              ),
              const Spacer(flex: 2,),
          
              ElevatedButton(
                onPressed: loginUser,
                child: Text(
                  "LOG IN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
          
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(SignupPage.route());
                },
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          // fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          
              const Spacer(flex: 12,),
          
            ],
          ),
        ),
      ),
    );
  }
}