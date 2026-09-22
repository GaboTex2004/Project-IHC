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
import '../widgets/match_results_list.dart';
import 'report_detail_page.dart';

bool isVisualAnalysisAvailable(LostPetReport report) =>
    const {'LOST', 'FOUND', 'HOMELESS'}.contains(report.reportType) &&
    report.isActive;

bool canSearchVisualMatches(LostPetReport report) =>
    report.reportType == 'LOST' && report.isActive;

class AiRecognitionPage extends StatelessWidget {
  const AiRecognitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LostPetBloc>()..add(const LoadMyReports()),
      child: const _AiRecognitionView(),
    );
  }
}

class _AiRecognitionView extends StatelessWidget {
  const _AiRecognitionView();

  void _load(BuildContext context) {
    context.read<LostPetBloc>().add(const LoadMyReports());
  }
  
  Widget _buildAnalysisResult(
    BuildContext context,
    LostPetReport report,
    LostPetState state,
  ) {
    if (state is ReportAnalysisLoading &&
        state.reportId == report.id) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Analizando fotografía con IA...'),
          ],
        ),
      );
    }

    if (state is ReportAnalysisError &&
        state.reportId == report.id) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No se pudo analizar: ${state.message}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final Map<String, dynamic> analysis;

    if (state is ReportAnalysisLoaded &&
        state.reportId == report.id) {
      analysis = state.analysis;
    } else if (state is ReportMatchesLoading &&
        state.reportId == report.id) {
      analysis = state.analysis;
    } else if (state is ReportMatchesLoaded &&
        state.reportId == report.id) {
      analysis = state.analysis;
    } else if (state is ReportMatchesError &&
        state.reportId == report.id) {
      analysis = state.analysis;
    } else {
      return const SizedBox.shrink();
    }

    final features = analysis['features'];

    if (features is! Map) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('El servidor devolvió un resultado inválido.'),
      );
    }

    const labels = {
      'species': 'Especie',
      'primary_color': 'Color principal',
      'secondary_color': 'Color secundario',
      'markings': 'Marcas',
      'coat_type': 'Tipo de pelaje',
      'ear_type': 'Tipo de orejas',
      'size': 'Tamaño',
      'distinctive_features': 'Características distintivas',
    };

    final isSearching = state is ReportMatchesLoading;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultado del reconocimiento',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ...labels.entries.map((entry) {
            final value = features[entry.key]?.toString().trim() ?? '';

            if (value.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${entry.value}: $value'),
            );
          }),

          const SizedBox(height: 16),

          if (canSearchVisualMatches(report)) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSearching
                    ? null
                    : () {
                        context.read<LostPetBloc>().add(
                          FindReportMatches(reportId: report.id),
                        );
                      },
                icon: const Icon(Icons.search),
                label: Text(
                  isSearching
                      ? 'Buscando coincidencias...'
                      : 'Buscar coincidencias',
                ),
              ),
            ),

            if (isSearching) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],

            if (state is ReportMatchesError) ...[
              const SizedBox(height: 12),
              Text(
                'No se pudieron buscar coincidencias: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            ],

            if (state is ReportMatchesLoaded) ...[
              const SizedBox(height: 16),
              MatchResultsList(
                result: state.matches,
                onOpenDetails: (reportId) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReportDetailPage(reportId: reportId),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PetTrackHeader(
        title: 'Reconocimiento IA',
        showBackButton: true,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<LostPetBloc, LostPetState>(
          builder: (context, state) {
            if (state is MyReportsLoading || state is LostPetInitial) {
              return const LoadingWidget(message: 'Cargando tus mascotas...');
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
              ReportAnalysisLoading() => state.reports,
              ReportAnalysisLoaded() => state.reports,
              ReportAnalysisError() => state.reports,
              ReportMatchesLoading() => state.reports,
              ReportMatchesLoaded() => state.reports,
              ReportMatchesError() => state.reports,
              _ => <LostPetReport>[],
            };

            final analyzableReports = reports
                .where(
                  isVisualAnalysisAvailable,
                )
                .toList();

            return RefreshIndicator(
              onRefresh: () async => _load(context),
              child: analyzableReports.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.pets_outlined,
                          size: 58,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'No tienes reportes activos para analizar',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                      itemCount: analyzableReports.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selecciona un reporte',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Analiza visualmente tus reportes activos. '
                                  'Las coincidencias solo se buscan desde '
                                  'mascotas perdidas.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final report = analyzableReports[index - 1];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Column(
                            children: [
                              ReportCard(
                                report: report,
                                onTap: () {
                                  context.read<LostPetBloc>().add(
                                    AnalyzeReport(reportId: report.id),
                                  );
                                },
                              ),
                              _buildAnalysisResult(context, report, state),
                            ],
                          ),
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
