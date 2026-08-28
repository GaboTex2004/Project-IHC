import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/lost_pet_report.dart';

class LostPetReportModel {
  final int id;
  final int userId;
  final String name;
  final String photo;
  final String characteristics;
  final String lastLocation;
  final String dateLost;
  final String contactInfo;
  final String createdAt;

  LostPetReportModel({
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

  static String _fullPhotoUrl(String photo) {
    if (photo.isEmpty) return photo;
    if (photo.startsWith('http')) return photo;
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
    return '$baseUrl$photo';
  }

  factory LostPetReportModel.fromJson(Map<String, dynamic> json) {
    return LostPetReportModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      photo: _fullPhotoUrl(json['photo'] ?? ''),
      characteristics: json['characteristics'],
      lastLocation: json['last_location'],
      dateLost: json['date_lost'],
      contactInfo: json['contact_info'],
      createdAt: json['created_at'] ?? '',
    );
  }

  LostPetReport toEntity() => LostPetReport(
    id: id,
    userId: userId,
    name: name,
    photo: photo,
    characteristics: characteristics,
    lastLocation: lastLocation,
    dateLost: dateLost,
    contactInfo: contactInfo,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'photo': photo,
      'characteristics': characteristics,
      'last_location': lastLocation,
      'date_lost': dateLost,
      'contact_info': contactInfo,
      'created_at': createdAt,
    };
  }
}
