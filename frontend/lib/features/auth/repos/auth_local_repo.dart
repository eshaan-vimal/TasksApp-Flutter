import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:frontend/models/user_model.dart';


class AuthLocalRepo 
{
  String tableName = 'users';
  Database? _database;


  Future<Database> get database async 
  {
    _database ??= await _initDb ();

    return _database!;
  }


  Future<Database> _initDb () async
  {
    final String dbPath = await getDatabasesPath();
    final String path = join (dbPath, 'auth.db');
    
    return openDatabase (path, version: 1, onCreate: (db, version) {
      return db.execute(
        '''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            token TEXT NOT NULL,
            name TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        '''
      );
    });
  }


  Future<void> insertUser (UserModel user) async
  {
    final db = await database;

    await db.insert(
      tableName, 
      user.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }


  Future<UserModel?> getUser () async
  {
    final db = await database;
    final users = await db.query(tableName, limit: 1);

    if (users.isNotEmpty)
    {
      return UserModel.fromMap(users.first);
    }

    return null;
  }
}