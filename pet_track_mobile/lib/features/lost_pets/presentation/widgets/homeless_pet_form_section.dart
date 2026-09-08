import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/generated/figma_tokens.dart';
import '../models/report_form_data.dart';
import 'custom_text_field.dart';
import 'report_dropdown_field.dart';

class HomelessPetFormSection extends StatelessWidget {
  final PetSpecies species;
  final PetSize size;
  final PetAgeRange ageRange;
  final PetGender gender;
  final bool hasIdentification;
  final IdentificationType identificationType;
  final TextEditingController breedController;
  final TextEditingController colorController;
  final TextEditingController characteristicsController;
  final TextEditingController identificationNumberController;
  final ValueChanged<PetSpecies> onSpeciesChanged;
  final ValueChanged<PetSize> onSizeChanged;
  final ValueChanged<PetAgeRange> onAgeChanged;
  final ValueChanged<PetGender> onGenderChanged;
  final ValueChanged<bool> onIdentificationChanged;
  final ValueChanged<IdentificationType> onIdentificationTypeChanged;

  const HomelessPetFormSection({super.key, required this.species, required this.size, required this.ageRange, required this.gender, required this.hasIdentification, required this.identificationType, required this.breedController, required this.colorController, required this.characteristicsController, required this.identificationNumberController, required this.onSpeciesChanged, required this.onSizeChanged, required this.onAgeChanged, required this.onGenderChanged, required this.onIdentificationChanged, required this.onIdentificationTypeChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.warningSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.secondary, width: 1.5)),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.home_outlined, color: AppColors.secondary), SizedBox(width: 12),
          Expanded(child: Text.rich(TextSpan(text: 'Reporte sin nombre\n', style: TextStyle(fontWeight: FontWeight.w700), children: [TextSpan(text: 'Este animal no tiene dueño conocido o fue encontrado en situación de calle.', style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary, height: 1.35))]))),
        ]),
      ),
      const SizedBox(height: SpacingToken.m),
      ReportDropdownField<PetSpecies>(label: 'Especie', value: species, values: PetSpecies.values, itemLabel: (v) => v.label, onChanged: (v) { if (v != null) onSpeciesChanged(v); }),
      const SizedBox(height: SpacingToken.m),
      CustomTextField(label: 'Raza', hint: 'No identificada', controller: breedController, prefixIcon: Icons.category_outlined, isRequired: false),
      const SizedBox(height: SpacingToken.m),
      CustomTextField(label: 'Color', hint: 'Ej: Café con blanco', controller: colorController, prefixIcon: Icons.palette_outlined),
      const SizedBox(height: SpacingToken.m),
      ReportDropdownField<PetSize>(label: 'Tamaño estimado', value: size, values: PetSize.values, itemLabel: (v) => v.label, onChanged: (v) { if (v != null) onSizeChanged(v); }),
      const SizedBox(height: SpacingToken.m),
      ReportDropdownField<PetAgeRange>(label: 'Edad aproximada', value: ageRange, values: PetAgeRange.values, itemLabel: (v) => v.label, onChanged: (v) { if (v != null) onAgeChanged(v); }, isRequired: false),
      const SizedBox(height: SpacingToken.m),
      ReportDropdownField<PetGender>(label: 'Género', value: gender, values: PetGender.values, itemLabel: (v) => v.label, onChanged: (v) { if (v != null) onGenderChanged(v); }),
      const SizedBox(height: SpacingToken.m),
      CustomTextField(label: 'Señas particulares', hint: 'Describe características distintivas', controller: characteristicsController, prefixIcon: Icons.notes_rounded, maxLines: 3, textInputAction: TextInputAction.newline),
      const SizedBox(height: 10),
      SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('¿Tiene collar o identificación?', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: const Text('Indica si tiene algún tipo de identificación'), value: hasIdentification, onChanged: onIdentificationChanged),
      if (hasIdentification) ...[
        const SizedBox(height: 12),
        ReportDropdownField<IdentificationType>(label: 'Tipo de identificación', value: identificationType, values: IdentificationType.values, itemLabel: (v) => v.label, onChanged: (v) { if (v != null) onIdentificationTypeChanged(v); }),
        const SizedBox(height: SpacingToken.m),
        CustomTextField(label: 'Número de identificación', hint: 'Ej: 982-000-123-456', controller: identificationNumberController, prefixIcon: Icons.badge_outlined, isRequired: false),
      ],
    ]);
  }
}
