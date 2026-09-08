import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/generated/figma_tokens.dart';
import '../models/pet_status.dart';
import '../models/report_form_data.dart';
import 'status_badge.dart';

class ReportSummaryCard extends StatelessWidget {
  final ReportFormData data;

  const ReportSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(data.photos.first.bytes, width: 72, height: 72, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(data.displayName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    if (data.reportType == ReportType.homeless)
                      const StatusBadge(status: PetStatus.homeless),
                  ],
                ),
                const SizedBox(height: 5),
                Text(data.descriptionLine, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: SpacingToken.xS),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
                  const SizedBox(width: 3),
                  Expanded(child: Text(data.lastLocation, style: const TextStyle(fontSize: 12, color: AppColors.textMuted), maxLines: 2)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
