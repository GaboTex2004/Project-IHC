import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/lost_pet_report.dart';
import '../bloc/lost_pet_bloc.dart';
import '../bloc/lost_pet_event.dart';
import '../models/report_form_data.dart';
import '../widgets/pet_track_header.dart';
import '../widgets/report_summary_card.dart';

class ReportSuccessPage extends StatelessWidget {
  final LostPetReport report;
  final ReportFormData formData;

  const ReportSuccessPage({super.key, required this.report, required this.formData});

  void _goHome(BuildContext context) {
    context.read<LostPetBloc>().add(const LoadReports());
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PetTrackHeader(
        actions: [IconButton(onPressed: () => _goHome(context), icon: const Icon(Icons.close_rounded))],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.success, width: 1.5)),
              child: const Column(children: [
                Icon(Icons.celebration_rounded, size: 54, color: AppColors.success),
                SizedBox(height: 10),
                Text('¡Reporte publicado!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.success)),
                SizedBox(height: 4),
                Text('El animal ha sido registrado en el sistema', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              ]),
            ),
            const SizedBox(height: 14),
            ReportSummaryCard(data: formData),
            const SizedBox(height: 14),
            _FutureActionsCard(),
            const SizedBox(height: 14),
            const _FutureStatisticsCard(),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => _goHome(context), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)), child: const Text('Ver listado'))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(onPressed: () => _goHome(context), icon: const Icon(Icons.home_outlined), label: const Text('Ir al inicio'))),
            ]),
            const SizedBox(height: 10),
            Text('Reporte #${report.id}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _FutureActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Acciones disponibles', style: TextStyle(fontWeight: FontWeight.w800)),
        SizedBox(height: 10),
        _FutureAction(icon: Icons.notifications_outlined, title: 'Recibir notificaciones'),
        _FutureAction(icon: Icons.auto_awesome_outlined, title: 'Reconocimiento IA'),
        _FutureAction(icon: Icons.share_outlined, title: 'Compartir reporte'),
      ]),
    );
  }
}

class _FutureAction extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FutureAction({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Icon(icon, size: 21), const SizedBox(width: 10), Expanded(child: Text(title)),
        const Text('Próximamente', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ]),
    );
  }
}

class _FutureStatisticsCard extends StatelessWidget {
  const _FutureStatisticsCard();

  @override
  Widget build(BuildContext context) {
    const labels = ['Coincidencias', 'Alcance', 'Mensajes'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Estadísticas del reporte', style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 9),
      Row(children: labels.map((label) => Expanded(child: Container(
        margin: EdgeInsets.only(right: label == labels.last ? 0 : 8),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [const Text('—', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textMuted))]),
      ))).toList()),
      const SizedBox(height: 7),
      const Text('Pendientes de integración con el servidor', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
    ]);
  }
}
