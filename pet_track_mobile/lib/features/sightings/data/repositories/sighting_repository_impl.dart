import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sighting.dart';
import '../../domain/repositories/sighting_repository.dart';
import '../datasources/sighting_remote_datasource.dart';

class SightingRepositoryImpl implements SightingRepository {
  final SightingRemoteDataSource remoteDataSource;
  SightingRepositoryImpl({required this.remoteDataSource});
  @override
  Future<Either<Failure, List<Sighting>>> getReportSightings(
    int reportId,
  ) async {
    try {
      final models = await remoteDataSource.getReportSightings(reportId);
      return Right(
        models
            .map((model) => model.toEntity(remoteDataSource.baseUrl))
            .toList(),
      );
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, Sighting>> create({
    required int reportId,
    required double latitude,
    required double longitude,
    required String locationDescription,
    required DateTime sightingDateTime,
    required String description,
    List<int>? photoBytes,
    String? photoName,
  }) async {
    try {
      final model = await remoteDataSource.create(
        reportId: reportId,
        latitude: latitude,
        longitude: longitude,
        locationDescription: locationDescription,
        sightingDateTime: sightingDateTime,
        description: description,
        photoBytes: photoBytes,
        photoName: photoName,
      );
      return Right(model.toEntity(remoteDataSource.baseUrl));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }
}
