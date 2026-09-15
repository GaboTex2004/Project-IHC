import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_track_mobile/features/lost_pets/domain/entities/lost_pet_report.dart';
import 'package:pet_track_mobile/features/lost_pets/presentation/pages/create_report_page.dart';
import 'package:pet_track_mobile/features/lost_pets/presentation/pages/report_creation_launcher.dart';
import 'package:pet_track_mobile/features/lost_pets/presentation/models/report_form_data.dart';
import 'package:pet_track_mobile/features/lost_pets/presentation/widgets/report_type_selector.dart';
import 'package:pet_track_mobile/theme/app_theme.dart';

LostPetReport report({
  required String reportType,
  String status = 'ACTIVE',
  int ownerId = 2,
}) => LostPetReport(
  id: 1,
  userId: ownerId,
  name: 'Max',
  photo: '',
  characteristics: 'Collar rojo',
  lastLocation: 'Parque',
  dateLost: '2026-09-15',
  contactInfo: '70000000',
  reportType: reportType,
  status: status,
);

void main() {
  Future<void> openIntentSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => openCreateReport(context),
              child: const Text('Abrir creación'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir creación'));
    await tester.pumpAndSettle();
  }

  testWidgets('Perdí mi mascota abre el formulario LOST sin selector FOUND', (
    tester,
  ) async {
    await openIntentSheet(tester);
    await tester.tap(find.text('Perdí mi mascota'));
    await tester.pumpAndSettle();

    final form = tester.widget<CreateReportPage>(find.byType(CreateReportPage));
    expect(form.initialReportType, ReportType.lost);
    expect(find.text('Reportar mascota perdida'), findsWidgets);
    expect(find.byType(ReportTypeSelector), findsNothing);
  });

  testWidgets('Encontré un animal conserva el selector FOUND/HOMELESS', (
    tester,
  ) async {
    await openIntentSheet(tester);
    await tester.tap(find.text('Encontré un animal'));
    await tester.pumpAndSettle();

    final form = tester.widget<CreateReportPage>(find.byType(CreateReportPage));
    expect(form.initialReportType, ReportType.namedPet);
    expect(find.byType(ReportTypeSelector), findsOneWidget);
    expect(find.text('Con nombre'), findsOneWidget);
    expect(find.text('Sin hogar'), findsOneWidget);
    await tester.tap(find.text('Sin hogar'));
    await tester.pump();
    expect(
      tester.widget<ReportTypeSelector>(find.byType(ReportTypeSelector)).value,
      ReportType.homeless,
    );
  });

  test('Perdí mi mascota envía LOST', () {
    expect(ReportType.lost.apiValue, 'LOST');
  });

  test('Con nombre continúa enviando FOUND', () {
    expect(ReportType.namedPet.apiValue, 'FOUND');
  });

  test('Sin hogar continúa enviando HOMELESS', () {
    expect(ReportType.homeless.apiValue, 'HOMELESS');
  });

  test('LOST ACTIVE ajeno permite reportar avistamiento y contactar', () {
    final lost = report(reportType: 'LOST');
    expect(lost.canReportSightingBy(3), isTrue);
    expect(lost.isActive && lost.userId != 3, isTrue);
  });

  test('FOUND y HOMELESS no permiten reportar avistamiento', () {
    expect(report(reportType: 'FOUND').canReportSightingBy(3), isFalse);
    expect(report(reportType: 'HOMELESS').canReportSightingBy(3), isFalse);
  });

  test('LOST RESOLVED y LOST propio no permiten reportar avistamiento', () {
    expect(
      report(reportType: 'LOST', status: 'RESOLVED').canReportSightingBy(3),
      isFalse,
    );
    expect(report(reportType: 'LOST').canReportSightingBy(2), isFalse);
  });
}
