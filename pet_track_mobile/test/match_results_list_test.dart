import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_track_mobile/features/lost_pets/presentation/widgets/match_results_list.dart';

Map<String, dynamic> resultWith(int count) => {
  'matches': List.generate(
    count,
    (index) => {
      'report_id': index + 12,
      'name': index == 0 ? 'Perro encontrado' : 'Candidato ${index + 1}',
      'score': 70 - index,
      'report_type': index.isEven ? 'HOMELESS' : 'FOUND',
    },
  ),
};

Widget subject(Map<String, dynamic> result, ValueChanged<int> onOpenDetails) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: MatchResultsList(
          result: result,
          onOpenDetails: onOpenDetails,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('muestra una coincidencia y abre el reporte encontrado', (
    tester,
  ) async {
    int? openedReportId;
    await tester.pumpWidget(
      subject(resultWith(1), (reportId) => openedReportId = reportId),
    );

    expect(find.text('Perro encontrado'), findsOneWidget);
    expect(find.text('Sin hogar'), findsOneWidget);
    expect(find.text('70/100'), findsOneWidget);
    expect(find.text('Ver detalles'), findsOneWidget);

    await tester.tap(find.text('Ver detalles'));
    expect(openedReportId, 12);
  });

  testWidgets('muestra múltiples coincidencias en una vista desplazable', (
    tester,
  ) async {
    await tester.pumpWidget(subject(resultWith(10), (_) {}));

    expect(find.byKey(const ValueKey('match-12')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('match-21')),
      500,
    );
    expect(find.byKey(const ValueKey('match-21')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra el estado vacío', (tester) async {
    await tester.pumpWidget(subject({'matches': <dynamic>[]}, (_) {}));

    expect(find.text('Sin coincidencias por ahora'), findsOneWidget);
  });

  testWidgets('mantiene contacto en la pantalla de detalles', (tester) async {
    await tester.pumpWidget(subject(resultWith(1), (_) {}));

    expect(find.text('Contactar'), findsNothing);
    expect(
      find.text('Podrás contactar al responsable desde los detalles.'),
      findsOneWidget,
    );
  });
}
