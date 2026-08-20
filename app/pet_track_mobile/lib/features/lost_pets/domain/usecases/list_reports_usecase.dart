import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/lost_pet_report.dart';
import '../repositories/lost_pet_repository.dart';

class ListReportsUseCase {
  final LostPetRepository repository;

  ListReportsUseCase({required this.repository});

  Future<Either<Failure, List<LostPetReport>>> call() async {
    return await repository.getReports();
  }
}
