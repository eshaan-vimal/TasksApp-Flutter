import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/features/auth/repos/auth_local_repo.dart';


class AuthRemoteRepo
{
  final storageService = StorageService();
  final authLocalRepo = AuthLocalRepo();


  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async
  {
    try
    {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/signup'),
        headers: {
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode != 201)
      {
        throw jsonDecode(res.body)['error'];
      }

      return UserModel.fromJson(res.body);
    }
    catch (error)
    {
      rethrow;
    }
  }


  Future<UserModel> login({
    required String email,
    required String password,
  }) async
  {
    try
    {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode != 200)
      {
        throw jsonDecode(res.body)['error'];
      }

      final user = UserModel.fromJson(res.body);

      if (user.token?.isNotEmpty ?? false)
      {
        storageService.setToken(user.token!);
      }
      await authLocalRepo.insertUser(user);

      return user;
    }
    catch (error)
    {
      rethrow;
    }
  }


  Future<UserModel> getUser () async
  {
    try
    {
      final token = await storageService.getToken();

      if (token == null)
      {
        throw "No token found";
      }

      final res = await http.get(
        Uri.parse('${Constants.backendUri}/auth'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      ).timeout(Duration(seconds: 3));

      if (res.statusCode != 200)
      {
        throw jsonDecode(res.body)['error'];
      }

      return UserModel.fromJson(res.body);
    }
    catch (error)
    {
      final user = await authLocalRepo.getUser();

      if (user != null)
      {
        return user;
      }
      
      rethrow;
    }
  }
}