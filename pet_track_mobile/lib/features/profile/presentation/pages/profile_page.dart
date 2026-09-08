import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/pet_track_bottom_navigation.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../chat/presentation/pages/messages_page.dart';
import '../../../lost_pets/presentation/pages/create_report_page.dart';
import '../../../lost_pets/presentation/pages/my_reports_page.dart';
import '../../../lost_pets/presentation/bloc/lost_pet_bloc.dart';
import '../../../lost_pets/presentation/bloc/lost_pet_event.dart';
import '../../../lost_pets/presentation/widgets/pet_track_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Esta función estará disponible en una próxima integración.',
        ),
      ),
    );
  }

  Future<void> _openMyReports(BuildContext context) async {
    final homeBloc = context.read<LostPetBloc>();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MyReportsPage()));
    homeBloc.add(const LoadReports());
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres cerrar tu sesión en Pet Track?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  void _selectDestination(
    BuildContext context,
    PetTrackDestination destination,
  ) {
    switch (destination) {
      case PetTrackDestination.profile:
        return;
      case PetTrackDestination.createReport:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreateReportPage()));
        return;
      case PetTrackDestination.home:
        Navigator.of(context).popUntil((route) => route.isFirst);
      case PetTrackDestination.messages:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MessagesPage()),
        );
        return;
      case PetTrackDestination.settings:
        _comingSoon(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final displayName = user == null
        ? 'Perfil'
        : user.fullName.isNotEmpty
        ? user.fullName
        : user.username;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PetTrackHeader(title: 'Perfil'),
        bottomNavigationBar: PetTrackBottomNavigation(
          selectedDestination: PetTrackDestination.profile,
          onDestinationSelected: (destination) =>
              _selectDestination(context, destination),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        displayName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (user != null && user.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        _ProfileCounter(value: '—', label: 'Mascotas'),
                        _ProfileCounter(value: '—', label: 'Reportes'),
                        _ProfileCounter(value: '—', label: 'Mensajes'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfileMenuItem(
                icon: Icons.pets_outlined,
                title: 'Mis mascotas',
                onTap: () => _comingSoon(context),
              ),
              _ProfileMenuItem(
                icon: Icons.campaign_outlined,
                title: 'Mis reportes',
                onTap: () => _openMyReports(context),
              ),
              _ProfileMenuItem(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Mensajes',
                onTap: () =>
                    _selectDestination(context, PetTrackDestination.messages),
              ),
              _ProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                title: 'Notificaciones',
                onTap: () => _comingSoon(context),
              ),
              _ProfileMenuItem(
                icon: Icons.auto_awesome_outlined,
                title: 'Reconocimiento IA',
                onTap: () => _comingSoon(context),
              ),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                onTap: () => _comingSoon(context),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: authState is AuthLoading
                    ? null
                    : () => _logout(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCounter extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileCounter({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
