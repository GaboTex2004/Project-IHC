import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PetImagePicker extends StatelessWidget {
  final File? selectedImage;
  final ValueChanged<File> onImageSelected;
  final VoidCallback onImageRemoved;

  const PetImagePicker({
    super.key,
    required this.selectedImage,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    Navigator.of(context).pop(); // Cerrar el modal bottom sheet
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        onImageSelected(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Seleccionar Fotografía',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Elige cómo deseas adjuntar la foto de la mascota',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                title: const Text(
                  'Tomar Fotografía',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Usa la cámara de tu dispositivo'),
                onTap: () => _pickImage(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F3D99).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF3F3D99),
                  ),
                ),
                title: const Text(
                  'Elegir de la Galería',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Selecciona una imagen guardada'),
                onTap: () => _pickImage(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6C63FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fotografía de la Mascota *',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        if (selectedImage == null)
          // Placeholder para seleccionar imagen
          InkWell(
            onTap: () => _showImageSourceDialog(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.35),
                  width: 1.8,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      size: 32,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Subir foto de la mascota',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Formatos JPG, PNG (Cámara o Galería)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Vista previa de la imagen seleccionada con controles
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Sombra en la parte superior para visibilidad de botones
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Botones de acción (Cambiar / Eliminar)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    IconButton.filled(
                      onPressed: () => _showImageSourceDialog(context),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        foregroundColor: const Color(0xFF1E293B),
                        padding: const EdgeInsets.all(8),
                      ),
                      tooltip: 'Cambiar imagen',
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: onImageRemoved,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(8),
                      ),
                      tooltip: 'Eliminar imagen',
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
