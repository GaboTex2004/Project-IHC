import 'package:equatable/equatable.dart';

class LostPetReport extends Equatable {
  final int id;
  final int userId;
  final String name;
  final String photo;
  final String characteristics;
  final String lastLocation;
  final String dateLost;
  final String contactInfo;
  final String createdAt;

  const LostPetReport({
    required this.id,
    required this.userId,
    required this.name,
    required this.photo,
    required this.characteristics,
    required this.lastLocation,
    required this.dateLost,
    required this.contactInfo,
    this.createdAt = '',
  });

  @override
  List<Object> get props => [id, userId, name, photo, characteristics, lastLocation, dateLost, contactInfo, createdAt];
}
