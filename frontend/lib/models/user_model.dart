import 'dart:convert';


class UserModel
{
  final String? token;
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.token,
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });


  factory UserModel.fromMap (Map<String,dynamic> map)
  {
    return UserModel(
      token: map['token'] ?? '',
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }


  factory UserModel.fromJson (String source) => UserModel.fromMap(json.decode(source));


  Map<String,dynamic> toMap ()
  {
    return <String,dynamic> {
      'token': token,
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
    };
  }


  String toJson () => json.encode(toMap());


  UserModel copyWith ({
    String? token,
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  })
  {
    return UserModel(
      token: token ?? this.token,
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }


  @override
  String toString ()
  {
    return "UserModel(token: $token, id: $id, email: $email, name: $name, createdAt: $createdAt, updatedAt: $updatedAt)";
  }


  @override
  bool operator == (covariant UserModel other)
  {
    if (identical(this, other))
    {
      return true;
    }

    return (
      other.token == token &&
      other.id == id &&
      other.email == email &&
      other.name == name &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt
    );
  }

  @override
  int get hashCode
  {
    return (
      token.hashCode ^
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode
    );
  }

}