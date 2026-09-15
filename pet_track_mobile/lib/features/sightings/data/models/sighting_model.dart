import '../../domain/entities/sighting.dart';

class SightingModel {
  final Map<String, dynamic> json;
  SightingModel.fromJson(this.json);
  Sighting toEntity(String baseUrl) {
    final rawPhoto = (json['photo'] ?? '').toString();
    return Sighting(
      id: json['id'] as int,
      reportId: json['report_id'] as int,
      reporterId: json['reporter_id'] as int,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      locationDescription: json['location_description'].toString(),
      sightingDateTime: DateTime.parse(json['sighting_datetime'].toString()),
      description: json['description'].toString(),
      photo: rawPhoto.isEmpty || rawPhoto.startsWith('http')
          ? rawPhoto
          : '$baseUrl$rawPhoto',
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}
