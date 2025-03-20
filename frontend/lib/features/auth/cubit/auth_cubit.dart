import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/auth/repos/auth_remote_repo.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/models/user_model.dart';

part 'auth_state.dart';


class AuthCubit extends Cubit<AuthState>
{
  final authRemoteRepo = AuthRemoteRepo();
  final storageService = StorageService();

  AuthCubit() : super(AuthInitial());


  void signup ({
    required String name,
    required String email,
    required String password,
  }) async
  {
    try
    {
      emit(AuthLoading());

      final user = await authRemoteRepo.signup(
        name: name, 
        email: email, 
        password: password
      );

      emit(AuthSignedUp());

      print(user.name);
      print(user.email);
    }
    catch (error)
    {
      emit(AuthError(error.toString()));
    }
  }


  void login ({
    required String email,
    required String password,
  }) async
  {
    try
    {
      emit(AuthLoading());

      final user = await authRemoteRepo.login(
        email: email, 
        password: password
      );

      if (user.token?.isNotEmpty ?? false)
      {
        storageService.setToken(user.token!);
      }

      emit(AuthLoggedIn(user));
    }
    catch (error)
    {
      emit(AuthError(error.toString()));
    }
  }


  void getUser () async
  {
    try
    {
      emit(AuthLoading());

      final user = await authRemoteRepo.getUser();

      emit(AuthLoggedIn(user));
    }
    catch (error)
    {
      emit(AuthError(error.toString()));
    }
  }
}