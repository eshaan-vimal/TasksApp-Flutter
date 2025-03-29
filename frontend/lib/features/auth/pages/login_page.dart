import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubits/auth_cubit.dart';

import 'package:frontend/features/auth/pages/signup_page.dart';
import 'package:frontend/features/home/pages/home_page.dart';



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

  bool isObscured = true;

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


  void handleLogin ()
  {
    if (formKey.currentState!.validate())
    {
      context.read<AuthCubit>().login(
        email: emailController.text.trim(), 
        password: passwordController.text.trim(),
      );
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
      body: BlocConsumer<AuthCubit,AuthState>(

        listener: (context, state) {

          if (state is AuthLoggedIn)
          {
            Navigator.of(context).pushReplacement(HomePage.route());

            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(
            //     content: Text("Log in successful!"),
            //   )
            // );
          }

          else if (state is AuthLoggedOut)
          {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Center(
                  child: Text("Logout succesful!"),
                )
              )
            );
          }

          else if (state is AuthError)
          {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text(state.error),
                ),
              )
            );
            print(state.error);
          }

        },

        builder: (context, state) {

          if (state is AuthLoading || state is AuthLoggedIn)
          {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              
                  const Text(
                    "Log In.",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 30,),
              
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter email",
                      prefixIcon: Icon(Icons.email_rounded),
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 15,),
              
                  TextFormField(
                    obscureText: isObscured,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: "Enter password",
                      prefixIcon: const Icon(Icons.key_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        }, 
                        icon: isObscured ? const Icon(Icons.visibility_rounded) : const Icon(Icons.visibility_off_rounded),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 30,),
              
                  ElevatedButton(
                    onPressed: handleLogin,
                    child: const Text(
                      "LOG IN",
                      style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 0.867),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 0, 127),
                              // fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              
                ],
              ),
            ),
          );

        }
      ),
    );
  }
}