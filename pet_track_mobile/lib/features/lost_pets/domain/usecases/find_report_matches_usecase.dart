
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/lost_pet_repository.dart';

class FindReportMatchesUseCase {
  final LostPetRepository repository;

  FindReportMatchesUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    int reportId,
  ) {
    return repository.findReportMatches(reportId);
  }
}