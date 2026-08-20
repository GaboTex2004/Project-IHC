import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/lost_pet_bloc.dart';
import '../bloc/lost_pet_event.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _characteristicsController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  DateTime? _dateLost;
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void dispose() {
    _nameController.dispose();
    _characteristicsController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = pickedFile.name;
      });
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate() && _dateLost != null && _imageBytes != null) {
      context.read<LostPetBloc>().add(CreateReport(
        name: _nameController.text,
        photoBytes: _imageBytes!,
        photoName: _imageName ?? 'photo.jpg',
        characteristics: _characteristicsController.text,
        lastLocation: _locationController.text,
        dateLost: _dateLost!.toIso8601String().split('T')[0],
        contactInfo: _contactController.text,
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(title: const Text('Reportar Mascota Perdida')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Agregar fotografía', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la mascota',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true, fillColor: Colors.white,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _characteristicsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Características',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true, fillColor: Colors.white,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Ingresa las características' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Última ubicación',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true, fillColor: Colors.white,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Ingresa la ubicación' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_dateLost != null ? 'Fecha: ${_dateLost!.toLocal().toString().split(' ')[0]}' : 'Seleccionar fecha de pérdida'),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE2E8F0))),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _dateLost = date);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Información de contacto',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true, fillColor: Colors.white,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Ingresa tu contacto' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Publicar Reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
