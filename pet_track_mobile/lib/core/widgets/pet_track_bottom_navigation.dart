import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum PetTrackDestination { profile, createReport, home, messages, settings }

class PetTrackBottomNavigation extends StatelessWidget {
  final PetTrackDestination selectedDestination;
  final ValueChanged<PetTrackDestination> onDestinationSelected;

  const PetTrackBottomNavigation({
    super.key,
    required this.selectedDestination,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _NavigationItem(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'Perfil',
                selected: selectedDestination == PetTrackDestination.profile,
                onTap: () => onDestinationSelected(PetTrackDestination.profile),
              ),
              _CreateReportItem(
                onTap: () =>
                    onDestinationSelected(PetTrackDestination.createReport),
              ),
              _NavigationItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Inicio',
                selected: selectedDestination == PetTrackDestination.home,
                onTap: () => onDestinationSelected(PetTrackDestination.home),
              ),
              _NavigationItem(
                icon: Icons.chat_bubble_outline_rounded,
                selectedIcon: Icons.chat_bubble_rounded,
                label: 'Mensajes',
                selected: selectedDestination == PetTrackDestination.messages,
                onTap: () =>
                    onDestinationSelected(PetTrackDestination.messages),
              ),
              _NavigationItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings_rounded,
                label: 'Ajustes',
                selected: selectedDestination == PetTrackDestination.settings,
                onTap: () =>
                    onDestinationSelected(PetTrackDestination.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          selected: selected,
          button: true,
          label: label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? AppColors.primary : AppColors.textMuted,
                size: 23,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateReportItem extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateReportItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: 'Crear reporte',
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Reportar',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
