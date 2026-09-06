import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/app_colors.dart';
import '../models/report_form_data.dart';

class PetImagePicker extends StatelessWidget {
  static const int maxPhotos = 5;
  final List<ReportPhoto> photos;
  final ValueChanged<List<ReportPhoto>> onChanged;

  const PetImagePicker({super.key, required this.photos, required this.onChanged});

  Future<ReportPhoto?> _toPhoto(XFile file) async {
    try {
      return ReportPhoto(bytes: await file.readAsBytes(), name: file.name);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    Navigator.of(context).pop();
    try {
      final files = await ImagePicker().pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
        limit: maxPhotos - photos.length,
      );
      final converted = await Future.wait(files.map(_toPhoto));
      onChanged([...photos, ...converted.whereType<ReportPhoto>()].take(maxPhotos).toList());
    } catch (_) {
      if (context.mounted) _showError(context);
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    Navigator.of(context).pop();
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (file == null) return;
      final photo = await _toPhoto(file);
      if (photo != null) onChanged([...photos, photo].take(maxPhotos).toList());
    } catch (_) {
      if (context.mounted) _showError(context);
    }
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo obtener la fotografía. Inténtalo nuevamente.')),
    );
  }

  void _showSourceSheet(BuildContext context) {
    if (photos.length >= maxPhotos) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Agregar fotografías', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('La primera foto se enviará al servidor actual.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.camera_alt_outlined)),
                title: const Text('Tomar una fotografía'),
                onTap: () => _takePhoto(sheetContext),
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.photo_library_outlined)),
                title: const Text('Elegir de la galería'),
                onTap: () => _pickFromGallery(sheetContext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fotos *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (photos.isEmpty)
          InkWell(
            onTap: () => _showSourceSheet(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textMuted, width: 1.5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 38),
                  SizedBox(height: 10),
                  Text('Toca para agregar fotos', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Máximo 5 fotos', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length < maxPhotos ? photos.length + 1 : photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == photos.length) {
                  return InkWell(
                    onTap: () => _showSourceSheet(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.add_rounded, size: 32),
                    ),
                  );
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(photos[index].bytes, width: 112, height: 112, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton.filled(
                        visualDensity: VisualDensity.compact,
                        iconSize: 17,
                        style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.7)),
                        onPressed: () {
                          final updated = [...photos]..removeAt(index);
                          onChanged(updated);
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                    if (index == 0)
                      const Positioned(
                        left: 6,
                        bottom: 6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.all(Radius.circular(6))),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                            child: Text('Principal', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
