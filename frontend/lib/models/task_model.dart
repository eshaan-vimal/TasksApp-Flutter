import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:frontend/core/constants/utils.dart';


class TaskModel 
{
  final String id;
  final String title;
  final String description;
  final Color colour;
  final String uid;
  final DateTime dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? isSynced;

  TaskModel ({
    required this.id,
    required this.title,
    required this.description,
    required this.colour,
    required this.uid,
    required this.dueAt,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced,
  });


  factory TaskModel.fromMap (Map<String,dynamic> map)
  {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      colour: hexToRgb(map['hexColour']),
      uid: map['uid'] as String,
      dueAt: DateTime.parse(map['dueAt']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isSynced: map['isSynced'] ?? 1,
    );
  }


  factory TaskModel.fromJson (String source) => TaskModel.fromMap(json.decode(source));


  Map<String,dynamic> toMap ()
  {
    return <String,dynamic> {
      'id': id,
      'title': title,
      'description': description,
      'hexColour': rgbToHex(colour),
      'uid': uid,
      'dueAt': dueAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ?? 1, 
    };
  }


  String toJson () => json.encode(toMap());


  TaskModel copyWith ({
    String? id,
    String? title,
    String? description,
    Color? colour,
    String? uid,
    DateTime? dueAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? isSynced,
  })
  {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colour: colour ?? this.colour,
      uid: uid ?? this.uid,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced ?? 1,
    );
  }


  @override
  String toString ()
  {
    return "UserModel(id: $id, title: $title, description: $description, colour: ${rgbToHex(colour)}, uid: $uid, dueAt: $dueAt, createdAt: $createdAt, updatedAt: $updatedAt), isSynced: ${isSynced ?? 1}";
  }


  @override
  bool operator == (covariant TaskModel other)
  {
    if (identical(this, other))
    {
      return true;
    }

    return (
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.colour == colour &&
      other.uid == uid &&
      other.dueAt == dueAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.isSynced == isSynced
    );
  }

  @override
  int get hashCode
  {
    return (
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      colour.hashCode ^
      uid.hashCode ^
      dueAt.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isSynced.hashCode
    );
  }

}