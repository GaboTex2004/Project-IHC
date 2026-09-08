import 'package:flutter/material.dart';
import '../models/report_form_data.dart';
import '../../../../theme/generated/figma_tokens.dart';
import 'custom_text_field.dart';
import 'report_dropdown_field.dart';

class NamedPetFormSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController breedController;
  final TextEditingController colorController;
  final TextEditingController characteristicsController;
  final PetSpecies species;
  final ValueChanged<PetSpecies> onSpeciesChanged;

  const NamedPetFormSection({super.key, required this.nameController, required this.breedController, required this.colorController, required this.characteristicsController, required this.species, required this.onSpeciesChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomTextField(label: 'Nombre de la mascota', hint: 'Ej: Max', controller: nameController, prefixIcon: Icons.pets_outlined),
      const SizedBox(height: SpacingToken.m),
      ReportDropdownField<PetSpecies>(label: 'Especie', value: species, values: PetSpecies.values, itemLabel: (value) => value.label, onChanged: (value) { if (value != null) onSpeciesChanged(value); }),
      const SizedBox(height: SpacingToken.m),
      CustomTextField(label: 'Raza', hint: 'Ej: Labrador', controller: breedController, prefixIcon: Icons.category_outlined, isRequired: false),
      const SizedBox(height: SpacingToken.m),
      CustomTextField(label: 'Color', hint: 'Ej: Dorado', controller: colorController, prefixIcon: Icons.palette_outlined),
      const SizedBox(height: SpacingToken.m),
      CustomTextField(label: 'Descripción', hint: 'Describe sus características distintivas', controller: characteristicsController, prefixIcon: Icons.notes_rounded, maxLines: 3, textInputAction: TextInputAction.newline),
    ]);
  }
}
