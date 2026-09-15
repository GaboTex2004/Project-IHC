import 'package:flutter_test/flutter_test.dart';
import 'package:pet_track_mobile/features/sightings/presentation/widgets/google_maps_link.dart';
import 'package:pet_track_mobile/features/sightings/data/models/sighting_model.dart';

void main() {
  test('Google Maps link is derived from coordinates and not stored', () {
    final uri = googleMapsUri(-17.783333, -63.183333);
    expect(uri.host, 'www.google.com');
    expect(uri.queryParameters['query'], '-17.783333,-63.183333');
    expect(uri.queryParameters['api'], '1');
  });

  test('sighting response maps exact coordinates', () {
    final sighting = SightingModel.fromJson({
      'id': 4,
      'report_id': 2,
      'reporter_id': 3,
      'latitude': '-17.783333',
      'longitude': '-63.183333',
      'location_description': 'Parque',
      'sighting_datetime': '2026-09-15T12:00:00Z',
      'description': 'Collar naranja',
      'photo': '',
      'created_at': '2026-09-15T13:00:00Z',
    }).toEntity('http://localhost:8000');
    expect(sighting.latitude, -17.783333);
    expect(sighting.longitude, -63.183333);
    expect(sighting.reportId, 2);
  });
}
