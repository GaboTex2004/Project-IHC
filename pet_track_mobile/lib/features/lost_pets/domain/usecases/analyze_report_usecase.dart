
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/lost_pet_repository.dart';

class AnalyzeReportUseCase {
  final LostPetRepository repository;

  AnalyzeReportUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    int reportId,
  ) {
    return repository.analyzeReport(reportId);
  }
}