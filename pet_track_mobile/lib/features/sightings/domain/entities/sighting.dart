import 'package:equatable/equatable.dart';

class Sighting extends Equatable {
  final int id;
  final int reportId;
  final int reporterId;
  final double latitude;
  final double longitude;
  final String locationDescription;
  final DateTime sightingDateTime;
  final String description;
  final String photo;
  final DateTime createdAt;

  const Sighting({
    required this.id,
    required this.reportId,
    required this.reporterId,
    required this.latitude,
    required this.longitude,
    required this.locationDescription,
    required this.sightingDateTime,
    required this.description,
    required this.photo,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
    id,
    reportId,
    reporterId,
    latitude,
    longitude,
    locationDescription,
    sightingDateTime,
    description,
    photo,
    createdAt,
  ];
}
