import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/lost_pet_report.dart';

abstract class LostPetRepository {
  Future<Either<Failure, List<LostPetReport>>> getReports();
  Future<Either<Failure, List<LostPetReport>>> getMyReports();
  Future<Either<Failure, LostPetReport>> getReportDetail(int reportId);
  Future<Either<Failure, LostPetReport>> createReport({
    required String name,
    required List<int> photoBytes,
    required String photoName,
    required String characteristics,
    required String lastLocation,
    required String dateLost,
    required String contactInfo,
    required String reportType,
  });
  Future<Either<Failure, LostPetReport>> resolveReport(int reportId);
  Future<Either<Failure, void>> deleteReport(int reportId);
}
