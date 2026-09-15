import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/generated/figma_tokens.dart';
import '../../../../theme/generated/figma_typography.dart';
import '../bloc/sighting_bloc.dart';
import '../bloc/sighting_event.dart';
import '../bloc/sighting_state.dart';
import '../models/sighting_draft.dart';
import '../widgets/google_maps_link.dart';

class SightingReviewPage extends StatelessWidget {
  final SightingDraft draft;
  final VoidCallback onEdit;
  const SightingReviewPage({
    super.key,
    required this.draft,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(SpacingToken.m),
    children: [
      const Text('Revisa el avistamiento', style: AppTextStyle.boldSubtitle),
      const SizedBox(height: SpacingToken.s),
      const Text(
        'Los datos se enviarán solamente cuando confirmes.',
        style: AppTextStyle.regularCaption,
      ),
      const SizedBox(height: SpacingToken.l),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(SpacingToken.m),
          child: Row(
            children: [
              if (draft.report.photo.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(SpacingToken.s),
                  child: Image.network(
                    draft.report.photo,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.pets, size: 48),
                  ),
                )
              else
                const Icon(Icons.pets, size: 48),
              const SizedBox(width: SpacingToken.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.report.displayName,
                      style: AppTextStyle.boldBodySmall,
                    ),
                    Text(
                      'Reporte #${draft.report.id}',
                      style: AppTextStyle.regularCaption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: SpacingToken.m),
      _SummaryRow(
        label: 'Latitud / longitud',
        value:
            '${draft.latitude!.toStringAsFixed(6)}, ${draft.longitude!.toStringAsFixed(6)}',
      ),
      _SummaryRow(label: 'Referencia', value: draft.locationDescription),
      GoogleMapsLink(latitude: draft.latitude!, longitude: draft.longitude!),
      const SizedBox(height: SpacingToken.m),
      _SummaryRow(
        label: 'Fecha y hora',
        value:
            '${draft.sightingDateTime!.day}/${draft.sightingDateTime!.month}/${draft.sightingDateTime!.year} ${draft.sightingDateTime!.hour.toString().padLeft(2, '0')}:${draft.sightingDateTime!.minute.toString().padLeft(2, '0')}',
      ),
      _SummaryRow(label: 'Descripción', value: draft.description),
      if (draft.photo != null) ...[
        const SizedBox(height: SpacingToken.s),
        Image.memory(draft.photo!.bytes, height: 180, fit: BoxFit.cover),
      ],
      const SizedBox(height: SpacingToken.xL),
      BlocBuilder<SightingBloc, SightingState>(
        builder: (context, state) => ElevatedButton.icon(
          onPressed: state is SightingSubmitting
              ? null
              : () => context.read<SightingBloc>().add(ConfirmSighting(draft)),
          icon: state is SightingSubmitting
              ? const SizedBox.square(
                  dimension: SpacingToken.m,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.surface,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(
            state is SightingSubmitting
                ? 'Enviando...'
                : 'Confirmar avistamiento',
          ),
        ),
      ),
      const SizedBox(height: SpacingToken.s),
      BlocBuilder<SightingBloc, SightingState>(
        builder: (context, state) => OutlinedButton(
          onPressed: state is SightingSubmitting ? null : onEdit,
          child: const Text('Volver a editar'),
        ),
      ),
    ],
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpacingToken.m),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.mediumCaption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: SpacingToken.xS),
        Text(value, style: AppTextStyle.regularBodySmall),
      ],
    ),
  );
}
