import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/auth/cubit/auth_cubit.dart';
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
    if (value == null || value.trim().isEmpty)
    {
      return "Field empty";
    }
    if (!RegExp(r"^[A-Za-z]+(?:[' -][A-Za-z]+)*$").hasMatch(value))
    {
      return "Invalid name";
    }

    return null;
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

    String errorText = "";

    if (password1Controller.text != password2Controller.text)
    {
      errorText += errorText.isEmpty ? "Passwords don't match" : "\nPasswords don't match";
    }
    if (value.length < 8)
    {
      errorText += errorText.isEmpty ? "Aleast 8 characters long" : "\nAleast 8 characters long";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) 
    {
      errorText += errorText.isEmpty ? "Atleast one uppercase letter" : "\nAtleast one uppercase letter";
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) 
    {
      errorText += errorText.isEmpty ? "Atleast one lowercase letter" : "\nAtleast one lowercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) 
    {
      errorText += errorText.isEmpty ? "Atleast one number" : "\nAtleast one number";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) 
    {
      errorText += errorText.isEmpty ? "Atleast one special character" : "\nAtleast one special character";
    }

    return errorText.isEmpty ? null : errorText;
  }

  
  void signupUser ()
  {
    if (formKey.currentState!.validate())
    {
      context.read<AuthCubit>().signup(
        name: nameController.text.trim(), 
        email: emailController.text.trim(), 
        password: password2Controller.text.trim(),
      );
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
      body: BlocConsumer<AuthCubit,AuthState>(

        listener: (context, state) {

          if (state is AuthError)
          {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              )
            );
          }

          else if (state is AuthSignedUp)
          {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sign up successfull!"),
              )
            );
          }

        },

        builder: (context, state) {

          if (state is AuthLoading)
          {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              
                  const Spacer(flex: 12,),
                  const Text(
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
                    decoration: const InputDecoration(
                      hintText: "Enter name",
                    ),
                    validator: validateName,
                  ),
                  const Spacer(flex: 1,),
              
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter email",
                    ),
                    validator: validateEmail,
                  ),
                  const Spacer(flex: 1,),
              
                  TextFormField(
                    obscureText: true,
                    controller: password1Controller,
                    decoration: const InputDecoration(
                      hintText: "Enter password",
                    ),
                  ),
                  const Spacer(flex: 1,),
          
                  TextFormField(
                    obscureText: true,
                    controller: password2Controller,
                    decoration: const InputDecoration(
                      hintText: "Confirm password",
                    ),
                    validator: validatePassword,
                  ),
                  const Spacer(flex: 2,),
              
                  ElevatedButton(
                    onPressed: () {
                      signupUser();
                    },
                    child: const Text(
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
                      text: const TextSpan(
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
          );

        }
      ),
    );
  }
}