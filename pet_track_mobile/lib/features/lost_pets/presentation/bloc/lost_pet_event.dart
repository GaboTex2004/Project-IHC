import 'package:equatable/equatable.dart';

abstract class LostPetEvent extends Equatable {
  const LostPetEvent();

  @override
  List<Object> get props => [];
}

class LoadReports extends LostPetEvent {
  const LoadReports();
}

class LoadReportDetail extends LostPetEvent {
  final int reportId;

  const LoadReportDetail({required this.reportId});

  @override
  List<Object> get props => [reportId];
}

class LoadMyReports extends LostPetEvent {
  const LoadMyReports();
}

class ResolveReport extends LostPetEvent {
  final int reportId;

  const ResolveReport({required this.reportId});

  @override
  List<Object> get props => [reportId];
}

class CreateReport extends LostPetEvent {
  final String name;
  final List<int> photoBytes;
  final String photoName;
  final String characteristics;
  final String lastLocation;
  final String dateLost;
  final String contactInfo;
  final String reportType;

  const CreateReport({
    required this.name,
    required this.photoBytes,
    required this.photoName,
    required this.characteristics,
    required this.lastLocation,
    required this.dateLost,
    required this.contactInfo,
    required this.reportType,
  });

  @override
  List<Object> get props => [
    name,
    photoBytes,
    photoName,
    characteristics,
    lastLocation,
    dateLost,
    contactInfo,
    reportType,
  ];
}
