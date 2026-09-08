import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/lost_pet_report.dart';
import '../repositories/lost_pet_repository.dart';

class GetReportDetailUseCase {
  final LostPetRepository repository;

  GetReportDetailUseCase({required this.repository});

  Future<Either<Failure, LostPetReport>> call(int reportId) async {
    return await repository.getReportDetail(reportId);
  }
}
