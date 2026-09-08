import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/generated/figma_tokens.dart';

class ReportFormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ReportFormSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
        const SizedBox(height: SpacingToken.s),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: SpacingToken.m),
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1)
            const SizedBox(height: SpacingToken.m),
        ],
      ],
    );
  }
}
