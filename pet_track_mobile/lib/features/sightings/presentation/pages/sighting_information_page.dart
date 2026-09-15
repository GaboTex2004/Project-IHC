import 'package:flutter/material.dart';
import '../../../../theme/generated/figma_tokens.dart';
import '../../../../theme/generated/figma_typography.dart';
import '../../../lost_pets/presentation/widgets/custom_text_field.dart';
import '../../../lost_pets/presentation/widgets/pet_image_picker.dart';
import '../../../lost_pets/presentation/models/report_form_data.dart';
import '../models/sighting_draft.dart';

class SightingInformationPage extends StatefulWidget {
  final SightingDraft draft;
  final VoidCallback onContinue;
  const SightingInformationPage({
    super.key,
    required this.draft,
    required this.onContinue,
  });
  @override
  State<SightingInformationPage> createState() =>
      _SightingInformationPageState();
}

class _SightingInformationPageState extends State<SightingInformationPage> {
  final formKey = GlobalKey<FormState>();
  late final descriptionController = TextEditingController(
    text: widget.draft.description,
  );
  late DateTime dateTime = widget.draft.sightingDateTime ?? DateTime.now();
  late List<ReportPhoto> photos = widget.draft.photo == null
      ? []
      : [widget.draft.photo!];
  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(
        () => dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          dateTime.hour,
          dateTime.minute,
        ),
      );
    }
  }

  Future<void> _chooseTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dateTime),
    );
    if (picked != null && mounted) {
      setState(
        () => dateTime = DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          picked.hour,
          picked.minute,
        ),
      );
    }
  }

  void _continue() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (dateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha del avistamiento no puede ser futura.'),
        ),
      );
      return;
    }
    widget.draft.sightingDateTime = dateTime;
    widget.draft.description = descriptionController.text.trim();
    widget.draft.photo = photos.isEmpty ? null : photos.first;
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: ListView(
      padding: const EdgeInsets.all(SpacingToken.m),
      children: [
        const Text('¿Qué viste?', style: AppTextStyle.boldSubtitle),
        const SizedBox(height: SpacingToken.s),
        const Text(
          'Describe lo que observaste. Una foto puede ayudar, pero es opcional.',
          style: AppTextStyle.regularCaption,
        ),
        const SizedBox(height: SpacingToken.l),
        CustomTextField(
          label: 'Descripción',
          hint: 'Vi una mascota parecida cerca del parque...',
          controller: descriptionController,
          prefixIcon: Icons.notes_outlined,
          maxLines: 4,
          validator: (raw) {
            final value = (raw ?? '').trim();
            if (value.isEmpty) return 'Describe el avistamiento';
            if (value.length > 2000) return 'Máximo 2000 caracteres';
            return null;
          },
        ),
        const SizedBox(height: SpacingToken.l),
        const Text(
          'Fecha y hora del avistamiento',
          style: AppTextStyle.mediumBodySmall,
        ),
        const SizedBox(height: SpacingToken.s),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _chooseDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                ),
              ),
            ),
            const SizedBox(width: SpacingToken.s),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _chooseTime,
                icon: const Icon(Icons.schedule_outlined),
                label: Text(
                  '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingToken.l),
        PetImagePicker(
          photos: photos,
          maxPhotosAllowed: 1,
          requiredPhoto: false,
          onChanged: (value) => setState(() => photos = value),
        ),
        const SizedBox(height: SpacingToken.xL),
        ElevatedButton(onPressed: _continue, child: const Text('Continuar')),
      ],
    ),
  );
}
