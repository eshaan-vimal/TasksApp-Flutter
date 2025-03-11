import 'package:flutter/material.dart';

import 'package:frontend/features/auth/pages/login_page.dart';


class SignupPage extends StatefulWidget
{
  const SignupPage ({super.key});


  static MaterialPageRoute route () => MaterialPageRoute(builder: (context) => const SignupPage());

  @override
  State<SignupPage> createState () => _SignupPageState();
}


class _SignupPageState extends State<SignupPage>
{
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController password1Controller = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  String? validateName (String? value)
  {

  }

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
    if (password1Controller.text != password2Controller.text)
    {
      return "Passwords don't match";
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

  
  void signupUser ()
  {
    if (formKey.currentState!.validate())
    {
      // Store data
    }
  }


  @override
  void dispose ()
  {
    nameController.dispose();
    emailController.dispose();
    password1Controller.dispose();
    password2Controller.dispose();
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
                "Sign Up.",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(flex: 2,),
          
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter name",
                ),
                validator: validateName,
              ),
              const Spacer(flex: 1,),
          
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter email",
                ),
                validator: validateEmail,
              ),
              const Spacer(flex: 1,),
          
              TextFormField(
                obscureText: true,
                controller: password1Controller,
                decoration: InputDecoration(
                  hintText: "Enter password",
                ),
                validator: validatePassword,
              ),
              const Spacer(flex: 1,),

              TextFormField(
                obscureText: true,
                controller: password2Controller,
                decoration: InputDecoration(
                  hintText: "Confirm password",
                ),
                validator: validatePassword,
              ),
              const Spacer(flex: 2,),
          
              ElevatedButton(
                onPressed: () {
                  signupUser();
                },
                child: Text(
                  "SIGN UP",
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
                  Navigator.of(context).pushReplacement(LoginPage.route());
                },
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: "Log In",
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