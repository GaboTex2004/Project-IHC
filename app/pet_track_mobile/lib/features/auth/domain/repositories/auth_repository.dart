import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> register(String username, String email, String password, {String firstName, String lastName});
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getProfile();
}
