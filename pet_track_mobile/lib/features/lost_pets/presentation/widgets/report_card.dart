import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/lost_pet_report.dart';

class ReportCard extends StatelessWidget {
  final LostPetReport report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: report.photo.isNotEmpty
                ? Image.network(
                    report.photo,
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _PhotoPlaceholder(),
                  )
                : const _PhotoPlaceholder(),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(report.characteristics, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 7),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
                  const SizedBox(width: 3),
                  Expanded(child: Text(report.lastLocation, style: const TextStyle(fontSize: 12, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                if (report.dateLost.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(report.dateLost, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(width: 82, height: 82, color: AppColors.surfaceMuted, child: const Icon(Icons.pets_rounded, size: 32, color: AppColors.textMuted));
  }
}
