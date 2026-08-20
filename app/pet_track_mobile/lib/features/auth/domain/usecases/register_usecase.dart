import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      params.username,
      params.email,
      params.password,
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }
}

class RegisterParams extends Equatable {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    this.firstName = '',
    this.lastName = '',
  });

  @override
  List<Object> get props => [username, email, password, firstName, lastName];
}
