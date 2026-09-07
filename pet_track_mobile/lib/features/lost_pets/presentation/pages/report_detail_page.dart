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
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/bloc/chat_state.dart';
import '../../../chat/presentation/pages/chat_page.dart';

class ReportDetailPage extends StatelessWidget {
  final int reportId;

  const ReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<LostPetBloc>()..add(LoadReportDetail(reportId: reportId)),
        ),
        BlocProvider(create: (_) => sl<ChatBloc>()),
      ],
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ConversationOpened) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatPage(conversation: state.conversation),
              ),
            );
          }
          if (state is ChatError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: _ReportDetailView(reportId: reportId),
      ),
    );
  }
}

class _ReportDetailView extends StatelessWidget {
  final int reportId;

  const _ReportDetailView({required this.reportId});

  void _loadDetail(BuildContext context) {
    context.read<LostPetBloc>().add(LoadReportDetail(reportId: reportId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PetTrackHeader(
        title: 'Detalle del reporte',
        showBackButton: true,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<LostPetBloc, LostPetState>(
          builder: (context, state) {
            if (state is LostPetDetailLoaded) {
              return _ReportDetailContent(report: state.report);
            }
            if (state is LostPetDetailNotFound) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: ErrorDisplayWidget(
                  message: state.message,
                  onRetry: () => _loadDetail(context),
                ),
              );
            }
            if (state is LostPetError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: ErrorDisplayWidget(
                  message: state.message,
                  onRetry: () => _loadDetail(context),
                ),
              );
            }
            return const LoadingWidget(message: 'Cargando detalle...');
          },
        ),
      ),
    );
  }
}

class _ReportDetailContent extends StatelessWidget {
  final LostPetReport report;

  const _ReportDetailContent({required this.report});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Esta función estará disponible en una próxima integración.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : -1;
    final canContact = report.isActive && report.userId != currentUserId;
    final opening = context.watch<ChatBloc>().state is ChatLoading;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: report.photo.isNotEmpty
                ? Image.network(
                    report.photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _DetailPhotoPlaceholder(),
                  )
                : const _DetailPhotoPlaceholder(),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.displayName,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reporte #${report.id}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Compartir',
              onPressed: () => _showComingSoon(context),
              icon: const Icon(Icons.share_outlined),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _DetailCard(
          title: 'Información del reporte',
          children: [
            _DetailRow(
              icon: Icons.notes_rounded,
              label: 'Características',
              value: report.characteristics,
            ),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Última ubicación',
              value: report.lastLocation,
            ),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha reportada',
              value: report.dateLost,
            ),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Contacto',
              value: report.contactInfo,
            ),
            _DetailRow(
              icon: Icons.flag_outlined,
              label: 'Tipo',
              value: report.reportType,
            ),
            _DetailRow(
              icon: Icons.info_outline_rounded,
              label: 'Estado',
              value: report.status,
            ),
            if (report.createdAt.isNotEmpty)
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: 'Creado',
                value: report.createdAt,
                isLast: true,
              )
            else
              const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 14),
        _DetailCard(
          title: 'Acciones',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (canContact)
                  _ActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: opening ? 'Abriendo...' : 'Contactar',
                    onTap: opening
                        ? null
                        : () => context.read<ChatBloc>().add(
                            OpenConversation(report.id),
                          ),
                  ),
                _ActionButton(
                  icon: Icons.map_outlined,
                  label: 'Ver mapa',
                  onTap: () => _showComingSoon(context),
                ),
                _ActionButton(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Buscar coincidencias',
                  onTap: () => _showComingSoon(context),
                ),
                _ActionButton(
                  icon: Icons.notifications_none_rounded,
                  label: 'Seguir reporte',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: AppColors.textSecondary),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 19),
      label: Text(label),
    );
  }
}

class _DetailPhotoPlaceholder extends StatelessWidget {
  const _DetailPhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: const Icon(
        Icons.pets_rounded,
        size: 72,
        color: AppColors.textMuted,
      ),
    );
  }
}
