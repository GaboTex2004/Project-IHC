import 'package:flutter/material.dart';
import '../../../../theme/generated/figma_tokens.dart';
import '../../../../theme/generated/figma_typography.dart';
import '../models/report_form_data.dart';
import 'create_report_page.dart';

Future<void> openCreateReport(BuildContext context) async {
  final reportType = await showModalBottomSheet<ReportType>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingToken.m,
          0,
          SpacingToken.m,
          SpacingToken.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Qué deseas reportar?',
              style: AppTextStyle.boldBodyLarge,
            ),
            const SizedBox(height: SpacingToken.m),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.search_rounded)),
              title: const Text('Perdí mi mascota'),
              subtitle: const Text('Reportar mascota perdida'),
              onTap: () => Navigator.of(sheetContext).pop(ReportType.lost),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.pets_rounded)),
              title: const Text('Encontré un animal'),
              subtitle: const Text('Con nombre o sin hogar'),
              onTap: () => Navigator.of(sheetContext).pop(ReportType.namedPet),
            ),
          ],
        ),
      ),
    ),
  );
  if (!context.mounted || reportType == null) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CreateReportPage(initialReportType: reportType),
    ),
  );
}
