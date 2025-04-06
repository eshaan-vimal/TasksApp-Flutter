import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/auth/cubits/auth_cubit.dart';
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

  bool isObscured = true;


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

  
  void handleSignup ()
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

          if (state is AuthSignedUp)
          {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Center(
                  child: Text("Sign up successfull!"),
                ),
              )
            );

            Navigator.of(context).pushReplacement(LoginPage.route());
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
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              
                  const Text(
                    "Sign Up.",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 30,),
              
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "Enter name",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: validateName,
                  ),
                  const SizedBox(height: 15,),
              
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 15,),
              
                  TextFormField(
                    obscureText: isObscured,
                    controller: password1Controller,
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
                  ),
                  const SizedBox(height: 15,),
          
                  TextFormField(
                    obscureText: isObscured,
                    controller: password2Controller,
                    decoration: InputDecoration(
                      hintText: "Confirm password",
                      prefixIcon: const Icon(Icons.lock_rounded),
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
                    onPressed: () {
                      handleSignup();
                    },
                    child: const Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: "Log In",
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