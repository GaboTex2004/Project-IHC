import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object> get props => [id, username, email, firstName, lastName];
}
