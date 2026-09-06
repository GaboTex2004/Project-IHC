import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../models/pet_status.dart';

class StatusBadge extends StatelessWidget {
  final PetStatus status;

  const StatusBadge({super.key, required this.status});

  Color get _color => switch (status) {
        PetStatus.homeless => AppColors.secondary,
        PetStatus.adopted => AppColors.success,
        PetStatus.lost => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(6)),
      child: Text(status.label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}
