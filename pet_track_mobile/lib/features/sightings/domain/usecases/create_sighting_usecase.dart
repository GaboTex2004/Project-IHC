import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sighting.dart';
import '../repositories/sighting_repository.dart';

class CreateSightingUseCase {
  final SightingRepository repository;
  CreateSightingUseCase({required this.repository});
  Future<Either<Failure, Sighting>> call({
    required int reportId,
    required double latitude,
    required double longitude,
    required String locationDescription,
    required DateTime sightingDateTime,
    required String description,
    List<int>? photoBytes,
    String? photoName,
  }) => repository.create(
    reportId: reportId,
    latitude: latitude,
    longitude: longitude,
    locationDescription: locationDescription,
    sightingDateTime: sightingDateTime,
    description: description,
    photoBytes: photoBytes,
    photoName: photoName,
  );
}
