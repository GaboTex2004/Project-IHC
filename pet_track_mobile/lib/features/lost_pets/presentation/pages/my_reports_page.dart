import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../injection/injection.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/lost_pet_report.dart';
import '../bloc/lost_pet_bloc.dart';
import '../bloc/lost_pet_event.dart';
import '../bloc/lost_pet_state.dart';
import '../widgets/pet_track_header.dart';
import '../widgets/report_card.dart';
import 'report_detail_page.dart';

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LostPetBloc>()..add(const LoadMyReports()),
      child: const _MyReportsView(),
    );
  }
}

class _MyReportsView extends StatelessWidget {
  const _MyReportsView();

  void _load(BuildContext context) {
    context.read<LostPetBloc>().add(const LoadMyReports());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PetTrackHeader(title: 'Mis reportes', showBackButton: true),
      body: SafeArea(
        top: false,
        child: BlocBuilder<LostPetBloc, LostPetState>(
          builder: (context, state) {
            if (state is MyReportsLoading || state is LostPetInitial) {
              return const LoadingWidget(message: 'Cargando tus reportes...');
            }
            if (state is LostPetError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: ErrorDisplayWidget(
                  message: state.message,
                  onRetry: () => _load(context),
                ),
              );
            }

            final reports = switch (state) {
              MyReportsLoaded() => state.reports,
              MyReportsUpdating() => state.reports,
              _ => <LostPetReport>[],
            };
            final updatingId = state is MyReportsUpdating
                ? state.reportId
                : null;

            return RefreshIndicator(
              onRefresh: () async => _load(context),
              child: reports.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.campaign_outlined,
                          size: 58,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Todavía no tienes reportes',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _MyReportItem(
                          report: report,
                          updating: updatingId == report.id,
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _MyReportItem extends StatelessWidget {
  final LostPetReport report;
  final bool updating;

  const _MyReportItem({required this.report, required this.updating});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportCard(
          report: report,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReportDetailPage(reportId: report.id),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _StatusLabel(report: report),
                const Spacer(),
                if (report.isActive)
                  FilledButton.tonalIcon(
                    onPressed: updating
                        ? null
                        : () => context.read<LostPetBloc>().add(
                            ResolveReport(reportId: report.id),
                          ),
                    icon: updating
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      updating ? 'Actualizando' : 'Marcar encontrado',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final LostPetReport report;

  const _StatusLabel({required this.report});

  @override
  Widget build(BuildContext context) {
    final resolved = report.isResolved;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          resolved ? Icons.check_circle_rounded : Icons.schedule_rounded,
          size: 18,
          color: resolved ? AppColors.success : AppColors.secondary,
        ),
        const SizedBox(width: 5),
        Text(
          resolved ? 'Encontrado' : 'Activo',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
