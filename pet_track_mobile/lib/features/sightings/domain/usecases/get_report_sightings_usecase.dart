import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sighting.dart';
import '../repositories/sighting_repository.dart';

class GetReportSightingsUseCase {
  final SightingRepository repository;
  GetReportSightingsUseCase({required this.repository});
  Future<Either<Failure, List<Sighting>>> call(int reportId) =>
      repository.getReportSightings(reportId);
}
