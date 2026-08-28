import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/lost_pet_remote_datasource.dart';
import '../../domain/entities/lost_pet_report.dart';
import '../../domain/repositories/lost_pet_repository.dart';

class LostPetRepositoryImpl implements LostPetRepository {
  final LostPetRemoteDataSource remoteDataSource;

  LostPetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LostPetReport>>> getReports() async {
    try {
      final models = await remoteDataSource.getReports();
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, LostPetReport>> createReport({
    required String name,
    required List<int> photoBytes,
    required String photoName,
    required String characteristics,
    required String lastLocation,
    required String dateLost,
    required String contactInfo,
  }) async {
    try {
      final model = await remoteDataSource.createReport(
        name: name,
        photoBytes: photoBytes,
        photoName: photoName,
        characteristics: characteristics,
        lastLocation: lastLocation,
        dateLost: dateLost,
        contactInfo: contactInfo,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReport(int reportId) async {
    return const Right(null);
  }
}
