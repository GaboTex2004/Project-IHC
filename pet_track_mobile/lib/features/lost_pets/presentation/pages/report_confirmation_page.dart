import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../theme/app_colors.dart';
import '../bloc/lost_pet_bloc.dart';
import '../bloc/lost_pet_event.dart';
import '../bloc/lost_pet_state.dart';
import '../models/report_form_data.dart';
import '../widgets/pet_track_header.dart';
import '../widgets/report_summary_card.dart';
import 'report_success_page.dart';

class ReportConfirmationPage extends StatelessWidget {
  final ReportFormData formData;

  const ReportConfirmationPage({super.key, required this.formData});

  String get _apiDate {
    final date = formData.date;
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _publish(BuildContext context) {
    if (!formData.reportType.isBackendSupported) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.construction_rounded, color: AppColors.secondary, size: 38),
          title: const Text('Reporte listo para integrarse'),
          content: const Text('La modalidad Sin hogar ya está preparada en la aplicación. Su publicación estará disponible cuando conectemos el nuevo servicio.'),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Entendido'))],
        ),
      );
      return;
    }

    final mainPhoto = formData.photos.first;
    context.read<LostPetBloc>().add(CreateReport(
      name: formData.name,
      photoBytes: mainPhoto.bytes,
      photoName: mainPhoto.name,
      characteristics: formData.characteristics,
      lastLocation: formData.lastLocation,
      dateLost: _apiDate,
      contactInfo: formData.contactInfo,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LostPetBloc, LostPetState>(
      listener: (context, state) {
        if (state is LostPetCreated) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => ReportSuccessPage(report: state.report, formData: formData),
          ));
        } else if (state is LostPetError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: const PetTrackHeader(title: 'Confirmar reporte', showBackButton: true),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: formData.reportType == ReportType.homeless ? AppColors.warningSurface : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: formData.reportType == ReportType.homeless ? AppColors.secondary : AppColors.border, width: 1.5),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(formData.reportType == ReportType.homeless ? Icons.warning_amber_rounded : Icons.fact_check_outlined, color: formData.reportType == ReportType.homeless ? AppColors.secondary : AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    formData.reportType == ReportType.homeless
                        ? 'Estás reportando un animal sin hogar. Revisa la información antes de continuar.'
                        : 'Revisa que los datos de la mascota sean correctos antes de publicar.',
                    style: const TextStyle(height: 1.4, fontWeight: FontWeight.w600),
                  )),
                ]),
              ),
              const SizedBox(height: 18),
              ReportSummaryCard(data: formData),
              const SizedBox(height: 18),
              _DetailRow(icon: Icons.calendar_today_outlined, label: 'Fecha', value: _apiDate),
              _DetailRow(icon: Icons.notes_rounded, label: 'Descripción', value: formData.characteristics),
              _DetailRow(icon: Icons.phone_outlined, label: 'Contacto', value: formData.contactInfo),
              if (formData.photos.length > 1)
                _DetailRow(icon: Icons.photo_library_outlined, label: 'Fotografías', value: '${formData.photos.length} seleccionadas'),
              if (!formData.reportType.isBackendSupported) ...[
                const SizedBox(height: 8),
                const Text('La publicación de esta modalidad requiere la próxima integración con el servidor.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
              const SizedBox(height: 28),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)), child: const Text('Editar'))),
                const SizedBox(width: 10),
                Expanded(child: BlocBuilder<LostPetBloc, LostPetState>(builder: (context, state) {
                  final loading = state is LostPetLoading;
                  return ElevatedButton.icon(
                    onPressed: loading ? null : () => _publish(context),
                    icon: loading
                        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_rounded),
                    label: Text(loading ? 'Publicando' : 'Confirmar', style: const TextStyle(fontWeight: FontWeight.w700)),
                  );
                })),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: AppColors.textSecondary), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 2), Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ])),
      ]),
    );
  }
}
