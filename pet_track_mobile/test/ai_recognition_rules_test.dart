import 'package:flutter_test/flutter_test.dart';
import 'package:pet_track_mobile/features/lost_pets/domain/entities/lost_pet_report.dart';
import 'package:pet_track_mobile/features/lost_pets/presentation/pages/ai_recognition_page.dart';

LostPetReport report({
  required String reportType,
  String status = 'ACTIVE',
}) => LostPetReport(
  id: 1,
  userId: 1,
  name: 'Mascota',
  photo: 'foto.jpg',
  characteristics: 'Características',
  lastLocation: 'Ubicación',
  dateLost: '2026-09-21',
  contactInfo: 'Contacto',
  reportType: reportType,
  status: status,
);

void main() {
  test('permite analizar LOST, FOUND y HOMELESS activos', () {
    for (final reportType in const ['LOST', 'FOUND', 'HOMELESS']) {
      expect(
        isVisualAnalysisAvailable(report(reportType: reportType)),
        isTrue,
      );
    }
  });

  test('no permite analizar reportes inactivos', () {
    expect(
      isVisualAnalysisAvailable(
        report(reportType: 'LOST', status: 'RESOLVED'),
      ),
      isFalse,
    );
  });

  test('solo LOST activo puede buscar coincidencias', () {
    expect(canSearchVisualMatches(report(reportType: 'LOST')), isTrue);
    expect(canSearchVisualMatches(report(reportType: 'FOUND')), isFalse);
    expect(canSearchVisualMatches(report(reportType: 'HOMELESS')), isFalse);
    expect(
      canSearchVisualMatches(
        report(reportType: 'LOST', status: 'RESOLVED'),
      ),
      isFalse,
    );
  });
}
