import 'package:flutter/material.dart';
import '../../../../theme/generated/figma_tokens.dart';

class ReportDropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool isRequired;

  const ReportDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.itemLabel,
    required this.onChanged,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(
          text: label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          children: [if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.redAccent))],
        )),
        const SizedBox(height: SpacingToken.s),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          items: values.map((item) => DropdownMenuItem(value: item, child: Text(itemLabel(item)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
