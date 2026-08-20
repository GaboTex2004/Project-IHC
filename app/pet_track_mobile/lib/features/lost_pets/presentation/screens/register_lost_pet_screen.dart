import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/datasources/lost_pet_remote_datasource.dart';
import '../../data/models/lost_pet_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/lost_date_picker_field.dart';
import '../widgets/pet_image_picker.dart';
import '../widgets/submit_report_button.dart';

class RegisterLostPetScreen extends StatefulWidget {
  final LostPetRemoteDataSource? dataSource;

  const RegisterLostPetScreen({super.key, this.dataSource});

  @override
  State<RegisterLostPetScreen> createState() => _RegisterLostPetScreenState();
}

class _RegisterLostPetScreenState extends State<RegisterLostPetScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para los campos del formulario
  final _nameController = TextEditingController();
  final _characteristicsController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  // Estado del formulario
  File? _selectedImage;
  DateTime? _selectedDate;
  bool _isLoading = false;

  late final LostPetRemoteDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? LostPetRemoteDataSourceImpl();
    // Por defecto sugerir la fecha de hoy
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _characteristicsController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  /// Limpia los campos del formulario tras un registro exitoso
  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _characteristicsController.clear();
    _locationController.clear();
    _contactController.clear();
    setState(() {
      _selectedImage = null;
      _selectedDate = DateTime.now();
    });
  }

  /// Valida y envía el reporte a la API de Django
  Future<void> _submitReport() async {
    // 1. Validar selección de fotografía
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('Por favor, selecciona una foto de la mascota'),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // 2. Validar campos de texto del formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 3. Formatear la fecha en formato YYYY-MM-DD para Django DateField
    final formattedDate =
        '${_selectedDate!.year.toString().padLeft(4, '0')}-'
        '${_selectedDate!.month.toString().padLeft(2, '0')}-'
        '${_selectedDate!.day.toString().padLeft(2, '0')}';

    // 4. Instanciar el modelo con los datos recolectados
    final petReport = LostPetModel(
      name: _nameController.text.trim(),
      characteristics: _characteristicsController.text.trim(),
      lastLocation: _locationController.text.trim(),
      dateLost: formattedDate,
      contactInfo: _contactController.text.trim(),
    );

    setState(() {
      _isLoading = true;
    });

    try {
      // 5. Enviar la petición MultipartRequest mediante el DataSource
      final result = await _dataSource.reportLostPet(
        pet: petReport,
        imageFile: _selectedImage!,
      );

      if (!mounted) return;

      // 6. Mostrar diálogo de éxito
      _showSuccessDialog(result);
      _resetForm();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(e.toString().replaceAll('Exception: ', ''))),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(LostPetModel pet) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF4CAF50),
            size: 44,
          ),
        ),
        title: const Text(
          '¡Reporte Publicado!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'El reporte de "${pet.name}" ha sido registrado exitosamente en la plataforma Pet Track.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Registrar Mascota Perdida',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Informativo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Proporciona la mayor cantidad de detalles posibles para facilitar la búsqueda en la comunidad.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Selector de Fotografía (Widget reutilizable)
                PetImagePicker(
                  selectedImage: _selectedImage,
                  onImageSelected: (image) {
                    setState(() {
                      _selectedImage = image;
                    });
                  },
                  onImageRemoved: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 2. Nombre de la Mascota
                CustomTextField(
                  label: 'Nombre de la Mascota',
                  hint: 'Ej. Max, Luna, Bobby',
                  controller: _nameController,
                  prefixIcon: Icons.pets_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor, ingresa el nombre de la mascota';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // 3. Características / Descripción
                CustomTextField(
                  label: 'Características y Descripción',
                  hint:
                      'Raza, color, tamaño, collar, señas particulares o comportamiento...',
                  controller: _characteristicsController,
                  prefixIcon: Icons.description_rounded,
                  maxLines: 4,
                  keyboardType:
                      TextInputType.multiline, // <-- ¡Agrega esto aquí!
                  textInputAction: TextInputAction.newline,
                  validator: (val) {
                    if (val == null || val.trim().length < 10) {
                      return 'Describe al menos 10 caracteres con detalles clave';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // 4. Última Ubicación
                CustomTextField(
                  label: 'Última Ubicación Conocida',
                  hint:
                      'Ej. Parque Central, Calle Los Álamos con Av. Principal',
                  controller: _locationController,
                  prefixIcon: Icons.location_on_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa la última ubicación donde fue vista';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // 5. Fecha de Pérdida
                LostDatePickerField(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 18),

                // 6. Información de Contacto
                CustomTextField(
                  label: 'Información de Contacto',
                  hint: 'Teléfono, WhatsApp o Correo electrónico',
                  controller: _contactController,
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Proporciona un número o medio de contacto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // 7. Botón de Envío
                SubmitReportButton(
                  onPressed: _isLoading ? null : _submitReport,
                  isLoading: _isLoading,
                  text: 'Publicar Reporte',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
