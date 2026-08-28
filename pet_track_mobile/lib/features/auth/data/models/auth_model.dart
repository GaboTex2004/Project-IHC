import '../../domain/entities/user.dart';

class AuthModel {
  final int userId;
  final String username;
  final String email;
  final String access;
  final String refresh;

  AuthModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.access,
    required this.refresh,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      access: json['access'],
      refresh: json['refresh'],
    );
  }

  User toEntity() => User(
    id: userId,
    username: username,
    email: email,
  );

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'access': access,
      'refresh': refresh,
    };
  }
}
