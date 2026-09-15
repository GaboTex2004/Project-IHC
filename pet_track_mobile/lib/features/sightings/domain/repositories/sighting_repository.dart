import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sighting.dart';

abstract class SightingRepository {
  Future<Either<Failure, List<Sighting>>> getReportSightings(int reportId);
  Future<Either<Failure, Sighting>> create({
    required int reportId,
    required double latitude,
    required double longitude,
    required String locationDescription,
    required DateTime sightingDateTime,
    required String description,
    List<int>? photoBytes,
    String? photoName,
  });
}
