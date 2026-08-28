import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/lost_pet_report.dart';
import '../repositories/lost_pet_repository.dart';

class CreateReportUseCase {
  final LostPetRepository repository;

  CreateReportUseCase({required this.repository});

  Future<Either<Failure, LostPetReport>> call(CreateReportParams params) async {
    return await repository.createReport(
      name: params.name,
      photoBytes: params.photoBytes,
      photoName: params.photoName,
      characteristics: params.characteristics,
      lastLocation: params.lastLocation,
      dateLost: params.dateLost,
      contactInfo: params.contactInfo,
    );
  }
}

class CreateReportParams extends Equatable {
  final String name;
  final List<int> photoBytes;
  final String photoName;
  final String characteristics;
  final String lastLocation;
  final String dateLost;
  final String contactInfo;

  const CreateReportParams({
    required this.name,
    required this.photoBytes,
    required this.photoName,
    required this.characteristics,
    required this.lastLocation,
    required this.dateLost,
    required this.contactInfo,
  });

  @override
  List<Object> get props => [name, photoBytes, photoName, characteristics, lastLocation, dateLost, contactInfo];
}
