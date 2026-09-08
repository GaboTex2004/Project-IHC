import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/lost_pet_report.dart';
import '../repositories/lost_pet_repository.dart';

class ResolveReportUseCase {
  final LostPetRepository repository;

  ResolveReportUseCase({required this.repository});

  Future<Either<Failure, LostPetReport>> call(int reportId) async {
    return await repository.resolveReport(reportId);
  }
}
