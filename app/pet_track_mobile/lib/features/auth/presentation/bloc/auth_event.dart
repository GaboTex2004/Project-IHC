import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const RegisterRequested({
    required this.username,
    required this.email,
    required this.password,
    this.firstName = '',
    this.lastName = '',
  });

  @override
  List<Object> get props => [username, email, password, firstName, lastName];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
