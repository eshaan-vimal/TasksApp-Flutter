import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';


class HomePage extends StatelessWidget
{
  const HomePage ({super.key});


  static MaterialPageRoute route () => MaterialPageRoute(builder: (context) => const HomePage());

  @override
  Widget build (BuildContext context) 
  {
    return Scaffold(
      body: Center(
        child: BlocBuilder<AuthCubit,AuthState>(
          builder: (context, state) {

            if (state is AuthLoggedIn)
            {
              return Text("Hello ${state.user.name}");
            }

            return Text("Hello Guest");
          }
        ),
      ),
    );
  }
}