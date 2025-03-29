import 'dart:async';

import 'package:frontend/core/services/connectivity_service.dart';
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
      if (await ConnectivityService().isOffline)
      {
        throw "Internet connection needed";
      }

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
      ).timeout(Duration(seconds: 5));

      if (res.statusCode != 201)
      {
        throw jsonDecode(res.body)['error'];
      }

      return UserModel.fromJson(res.body);
    }
    on TimeoutException catch (_)
    {
      throw "Failed to connect to the server";
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
      if (await ConnectivityService().isOffline)
      {
        throw "Internet connection needed";
      }

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: 5));

      if (res.statusCode != 200)
      {
        throw jsonDecode(res.body)['error'];
      }

      return UserModel.fromJson(res.body);
    }
    on TimeoutException catch (_)
    {
      throw "Failed to connect to the server";
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
      if (await ConnectivityService().isOffline)
      {
        throw "Device offline";
      }

      final token = await storageService.getToken();
      if (token == null)
      {
        throw "Please login";
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
    on TimeoutException catch (_)
    {
      throw "Failed to connect to the server";
    }
    catch (error)
    { 
      throw "Auto login failed";
    }
  }
}