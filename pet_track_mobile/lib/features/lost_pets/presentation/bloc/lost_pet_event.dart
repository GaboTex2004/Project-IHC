import 'package:equatable/equatable.dart';

abstract class LostPetEvent extends Equatable {
  const LostPetEvent();

  @override
  List<Object> get props => [];
}

class LoadReports extends LostPetEvent {
  const LoadReports();
}

class CreateReport extends LostPetEvent {
  final String name;
  final List<int> photoBytes;
  final String photoName;
  final String characteristics;
  final String lastLocation;
  final String dateLost;
  final String contactInfo;

  const CreateReport({
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
