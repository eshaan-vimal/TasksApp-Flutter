import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class StorageService
{
  static const String _jwtKey = 'x-auth-token';
  final _storage = const FlutterSecureStorage();

  static final StorageService _instance = StorageService._internal();
  StorageService._internal();

  factory StorageService () => _instance;


  Future<void> setToken (String token) async
  {
    await _storage.write(key: _jwtKey, value: token);
  }


  Future<String?> getToken () async
  {
    return _storage.read(key: _jwtKey);
  }


  Future<void> deleteToken () async 
  {
    await _storage.delete(key: _jwtKey);
  }
}