import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/lost_pet_report.dart';
import '../bloc/lost_pet_bloc.dart';
import '../bloc/lost_pet_event.dart';
import '../bloc/lost_pet_state.dart';
import '../widgets/pet_track_header.dart';
import '../widgets/report_card.dart';
import 'create_report_page.dart';

enum _ReportFilter { all, recent, withPhoto }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _ReportFilter _filter = _ReportFilter.all;
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LostPetBloc>().add(const LoadReports());
    _searchController.addListener(_refreshSearch);
  }

  void _refreshSearch() => setState(() {});

  @override
  void dispose() {
    _searchController.removeListener(_refreshSearch);
    _searchController.dispose();
    super.dispose();
  }

  List<LostPetReport> _visibleReports(List<LostPetReport> source) {
    var reports = source.where((report) {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) return true;
      return report.name.toLowerCase().contains(query) ||
          report.characteristics.toLowerCase().contains(query) ||
          report.lastLocation.toLowerCase().contains(query);
    }).toList();

    if (_filter == _ReportFilter.withPhoto) {
      reports = reports.where((report) => report.photo.isNotEmpty).toList();
    } else if (_filter == _ReportFilter.recent && reports.length > 10) {
      reports = reports.take(10).toList();
    }
    return reports;
  }

  void _openCreateReport() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateReportPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PetTrackHeader(actions: [
        IconButton(
          tooltip: 'Buscar',
          onPressed: () => setState(() {
            _searching = !_searching;
            if (!_searching) _searchController.clear();
          }),
          icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
        ),
        IconButton(tooltip: 'Notificaciones (próximamente)', onPressed: null, icon: const Icon(Icons.notifications_none_rounded)),
        IconButton(tooltip: 'Perfil (próximamente)', onPressed: null, icon: const Icon(Icons.person_outline_rounded)),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateReport,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Reportar', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Animales reportados', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Consulta los reportes publicados por la comunidad', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              if (_searching) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Buscar por nombre, descripción o ubicación'),
                ),
              ],
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _FilterChip(label: 'Todos', selected: _filter == _ReportFilter.all, onSelected: () => setState(() => _filter = _ReportFilter.all)),
                  _FilterChip(label: 'Recientes', selected: _filter == _ReportFilter.recent, onSelected: () => setState(() => _filter = _ReportFilter.recent)),
                  _FilterChip(label: 'Con foto', selected: _filter == _ReportFilter.withPhoto, onSelected: () => setState(() => _filter = _ReportFilter.withPhoto)),
                  const _PendingFilterChip(label: 'Perros'),
                  const _PendingFilterChip(label: 'Gatos'),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: BlocBuilder<LostPetBloc, LostPetState>(builder: (context, state) {
              if (state is LostPetLoading || state is LostPetInitial || state is LostPetCreated) {
                return const LoadingWidget(message: 'Cargando reportes...');
              }
              if (state is LostPetError) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: ErrorDisplayWidget(message: state.message, onRetry: () => context.read<LostPetBloc>().add(const LoadReports())),
                );
              }
              if (state is LostPetLoaded) {
                final reports = _visibleReports(state.reports);
                return RefreshIndicator(
                  onRefresh: () async => context.read<LostPetBloc>().add(const LoadReports()),
                  child: reports.isEmpty
                      ? ListView(children: const [SizedBox(height: 110), Icon(Icons.pets_outlined, size: 54, color: AppColors.textMuted), SizedBox(height: 12), Text('No hay reportes para mostrar', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary))])
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: reports.length,
                          itemBuilder: (_, index) => ReportCard(report: reports[index]),
                        ),
                );
              }
              return const SizedBox.shrink();
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onSelected(), selectedColor: AppColors.primary, labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary)),
    );
  }
}

class _PendingFilterChip extends StatelessWidget {
  final String label;

  const _PendingFilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(message: 'Disponible con la próxima integración', child: FilterChip(label: Text(label), onSelected: null)),
    );
  }
}
