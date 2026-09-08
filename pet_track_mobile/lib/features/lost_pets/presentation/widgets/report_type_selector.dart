import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/generated/figma_tokens.dart';
import '../models/report_form_data.dart';

class ReportTypeSelector extends StatelessWidget {
  final ReportType value;
  final ValueChanged<ReportType> onChanged;

  const ReportTypeSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingToken.xS),
      decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: ReportType.values.map((type) {
          final selected = type == value;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(type),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: selected
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(type == ReportType.namedPet ? Icons.pets_rounded : Icons.home_outlined, size: 19),
                    const SizedBox(width: 7),
                    Text(type.label, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
