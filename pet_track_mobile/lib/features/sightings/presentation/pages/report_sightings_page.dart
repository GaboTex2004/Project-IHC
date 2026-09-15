import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection/injection.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/generated/figma_tokens.dart';
import '../../../../theme/generated/figma_typography.dart';
import '../../../lost_pets/domain/entities/lost_pet_report.dart';
import '../../../lost_pets/presentation/widgets/pet_track_header.dart';
import '../../domain/entities/sighting.dart';
import '../bloc/sighting_bloc.dart';
import '../bloc/sighting_event.dart';
import '../bloc/sighting_state.dart';
import '../widgets/google_maps_link.dart';

class ReportSightingsPage extends StatelessWidget {
  final LostPetReport report;
  const ReportSightingsPage({super.key, required this.report});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<SightingBloc>()..add(LoadReportSightings(report.id)),
    child: _ReportSightingsView(report: report),
  );
}

class _ReportSightingsView extends StatelessWidget {
  final LostPetReport report;
  const _ReportSightingsView({required this.report});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: const PetTrackHeader(title: 'Avistamientos', showBackButton: true),
    body: BlocBuilder<SightingBloc, SightingState>(
      builder: (context, state) {
        if (state is SightingsLoading || state is SightingInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SightingFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingToken.m),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: SpacingToken.m),
                  OutlinedButton.icon(
                    onPressed: () => context.read<SightingBloc>().add(
                      LoadReportSightings(report.id),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        final sightings = (state as SightingsLoaded).sightings;
        if (sightings.isEmpty) {
          return const Center(
            child: Text(
              'Aún no hay avistamientos para este reporte.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              context.read<SightingBloc>().add(LoadReportSightings(report.id)),
          child: ListView.separated(
            padding: const EdgeInsets.all(SpacingToken.m),
            itemCount: sightings.length,
            separatorBuilder: (_, _) => const SizedBox(height: SpacingToken.s),
            itemBuilder: (_, index) =>
                _SightingCard(sighting: sightings[index]),
          ),
        );
      },
    ),
  );
}

class _SightingCard extends StatelessWidget {
  final Sighting sighting;
  const _SightingCard({required this.sighting});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(SpacingToken.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${sighting.sightingDateTime.toLocal().day}/${sighting.sightingDateTime.toLocal().month}/${sighting.sightingDateTime.toLocal().year} · ${sighting.sightingDateTime.toLocal().hour.toString().padLeft(2, '0')}:${sighting.sightingDateTime.toLocal().minute.toString().padLeft(2, '0')}',
            style: AppTextStyle.mediumBodySmall,
          ),
          const SizedBox(height: SpacingToken.s),
          Text(
            sighting.locationDescription,
            style: AppTextStyle.regularBodySmall,
          ),
          const SizedBox(height: SpacingToken.s),
          Text(sighting.description, style: AppTextStyle.regularCaption),
          const SizedBox(height: SpacingToken.s),
          Text(
            'Latitud ${sighting.latitude.toStringAsFixed(6)} · Longitud ${sighting.longitude.toStringAsFixed(6)}',
            style: AppTextStyle.regularMicro,
          ),
          if (sighting.photo.isNotEmpty) ...[
            const SizedBox(height: SpacingToken.s),
            Image.network(
              sighting.photo,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image_outlined),
            ),
          ],
          const SizedBox(height: SpacingToken.s),
          GoogleMapsLink(
            latitude: sighting.latitude,
            longitude: sighting.longitude,
          ),
        ],
      ),
    ),
  );
}
