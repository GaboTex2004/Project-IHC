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
  final String reportType;
  final String status;
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
    this.reportType = 'LOST',
    this.status = 'ACTIVE',
    this.createdAt = '',
  });

  String get displayName => name.trim().isEmpty ? 'Sin nombre' : name;
  bool get isActive => status == 'ACTIVE';
  bool get isResolved => status == 'RESOLVED';

  @override
  List<Object> get props => [
    id,
    userId,
    name,
    photo,
    characteristics,
    lastLocation,
    dateLost,
    contactInfo,
    reportType,
    status,
    createdAt,
  ];
}
