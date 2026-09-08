import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../models/report_form_data.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/homeless_pet_form_section.dart';
import '../widgets/lost_date_picker_field.dart';
import '../widgets/named_pet_form_section.dart';
import '../widgets/pet_image_picker.dart';
import '../widgets/pet_track_header.dart';
import '../widgets/report_form_section.dart';
import '../widgets/report_type_selector.dart';
import 'report_confirmation_page.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _characteristicsController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _identificationNumberController = TextEditingController();

  ReportType _reportType = ReportType.namedPet;
  PetSpecies _species = PetSpecies.dog;
  PetSize _size = PetSize.medium;
  PetAgeRange _ageRange = PetAgeRange.unknown;
  PetGender _gender = PetGender.unknown;
  IdentificationType _identificationType = IdentificationType.tag;
  bool _hasIdentification = false;
  DateTime? _date;
  List<ReportPhoto> _photos = const [];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _characteristicsController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _identificationNumberController.dispose();
    super.dispose();
  }

  void _reviewReport() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _date == null || _photos.isEmpty) {
      final message = _photos.isEmpty
          ? 'Agrega al menos una fotografía.'
          : _date == null
              ? 'Selecciona la fecha del reporte.'
              : 'Revisa los campos obligatorios.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    final data = ReportFormData(
      reportType: _reportType,
      name: _nameController.text.trim(),
      species: _species,
      breed: _breedController.text.trim(),
      color: _colorController.text.trim(),
      size: _size,
      ageRange: _ageRange,
      gender: _gender,
      hasIdentification: _hasIdentification,
      identificationType: _hasIdentification ? _identificationType : null,
      identificationNumber: _identificationNumberController.text.trim(),
      characteristics: _characteristicsController.text.trim(),
      lastLocation: _locationController.text.trim(),
      date: _date!,
      contactInfo: _contactController.text.trim(),
      photos: List.unmodifiable(_photos),
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReportConfirmationPage(formData: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const PetTrackHeader(title: 'Reportar animal', showBackButton: true),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
            children: [
              const Text('Reportar animal encontrado', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              const Text('Ayuda a reunir a una mascota con su familia', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              ReportTypeSelector(
                value: _reportType,
                onChanged: (value) => setState(() => _reportType = value),
              ),
              const SizedBox(height: 28),
              ReportFormSection(
                title: 'Datos del animal',
                children: [
                  if (_reportType == ReportType.namedPet)
                    NamedPetFormSection(
                      nameController: _nameController,
                      breedController: _breedController,
                      colorController: _colorController,
                      characteristicsController: _characteristicsController,
                      species: _species,
                      onSpeciesChanged: (value) => setState(() => _species = value),
                    )
                  else
                    HomelessPetFormSection(
                      species: _species,
                      size: _size,
                      ageRange: _ageRange,
                      gender: _gender,
                      hasIdentification: _hasIdentification,
                      identificationType: _identificationType,
                      breedController: _breedController,
                      colorController: _colorController,
                      characteristicsController: _characteristicsController,
                      identificationNumberController: _identificationNumberController,
                      onSpeciesChanged: (value) => setState(() => _species = value),
                      onSizeChanged: (value) => setState(() => _size = value),
                      onAgeChanged: (value) => setState(() => _ageRange = value),
                      onGenderChanged: (value) => setState(() => _gender = value),
                      onIdentificationChanged: (value) => setState(() => _hasIdentification = value),
                      onIdentificationTypeChanged: (value) => setState(() => _identificationType = value),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              ReportFormSection(
                title: 'Ubicación y contacto',
                children: [
                  CustomTextField(
                    label: 'Ubicación donde fue encontrado',
                    hint: 'Ej: Parque Central, Zona 1',
                    controller: _locationController,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  LostDatePickerField(
                    selectedDate: _date,
                    label: 'Fecha del encuentro',
                    hint: 'Selecciona la fecha del encuentro',
                    onDateSelected: (value) => setState(() => _date = value),
                  ),
                  CustomTextField(
                    label: 'Información de contacto',
                    hint: 'Ej: 70000000',
                    controller: _contactController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ReportFormSection(
                title: 'Fotografías',
                children: [PetImagePicker(photos: _photos, onChanged: (value) => setState(() => _photos = value))],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), foregroundColor: AppColors.textPrimary),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _reviewReport,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Revisar', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
