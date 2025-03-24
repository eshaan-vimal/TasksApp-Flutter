part of 'auth_cubit.dart';


sealed class AuthState {}


class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSignedUp extends AuthState {}

class AuthLoggedIn extends AuthState 
{
  final UserModel user;
  AuthLoggedIn(this.user);
}

class AuthError extends AuthState 
{
  final String error;
  AuthError(this.error);
}