import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/auth/repos/auth_remote_repo.dart';
import 'package:frontend/features/home/repos/task_local_repo.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/features/auth/repos/auth_local_repo.dart';

part 'auth_state.dart';


class AuthCubit extends Cubit<AuthState>
{
  final authRemoteRepo = AuthRemoteRepo();
  final authLocalRepo = AuthLocalRepo();

  final taskLocalRepo = TaskLocalRepo();
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
      await authLocalRepo.insertUser(user);

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
      try
      {
        final user = await authLocalRepo.getUser();

        if (user == null)
        {
          emit(AuthError("No user found"));
          return;
        }

        emit(AuthLoggedIn(user));
      }
      catch (error)
      {
        emit(AuthError(error.toString()));
      }
    }
  }


  void logout () async
  {
    try
    {
      emit(AuthLoading());

      await authLocalRepo.deleteUserTable();
      await taskLocalRepo.deleteTaskTable();

      await storageService.deleteToken();

      emit(AuthLoggedOut());
    }
    catch (error)
    {
      emit(AuthError(error.toString()));
    }
  }
}