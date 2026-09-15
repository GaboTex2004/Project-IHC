import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/generated/figma_tokens.dart';
import '../../../../theme/generated/figma_typography.dart';
import '../../../lost_pets/presentation/widgets/custom_text_field.dart';
import '../bloc/sighting_bloc.dart';
import '../bloc/sighting_event.dart';
import '../bloc/sighting_state.dart';
import '../models/sighting_draft.dart';
import '../widgets/google_maps_link.dart';

class SightingLocationPage extends StatefulWidget {
  final SightingDraft draft;
  final VoidCallback onContinue;
  const SightingLocationPage({
    super.key,
    required this.draft,
    required this.onContinue,
  });
  @override
  State<SightingLocationPage> createState() => _SightingLocationPageState();
}

class _SightingLocationPageState extends State<SightingLocationPage> {
  final formKey = GlobalKey<FormState>();
  late final latitudeController = TextEditingController(
    text: widget.draft.latitude?.toStringAsFixed(6) ?? '',
  );
  late final longitudeController = TextEditingController(
    text: widget.draft.longitude?.toStringAsFixed(6) ?? '',
  );
  late final referenceController = TextEditingController(
    text: widget.draft.locationDescription,
  );

  @override
  void initState() {
    super.initState();
    latitudeController.addListener(_refreshCoordinates);
    longitudeController.addListener(_refreshCoordinates);
  }

  void _refreshCoordinates() {
    if (mounted) setState(() {});
  }

  double? get _latitude =>
      double.tryParse(latitudeController.text.trim().replaceAll(',', '.'));
  double? get _longitude =>
      double.tryParse(longitudeController.text.trim().replaceAll(',', '.'));
  bool get _hasValidCoordinates =>
      _latitude != null &&
      _longitude != null &&
      _latitude!.isFinite &&
      _longitude!.isFinite &&
      _latitude! >= -90 &&
      _latitude! <= 90 &&
      _longitude! >= -180 &&
      _longitude! <= 180;

  @override
  void dispose() {
    latitudeController.removeListener(_refreshCoordinates);
    longitudeController.removeListener(_refreshCoordinates);
    latitudeController.dispose();
    longitudeController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  String? _coordinateValidator(String? raw, double min, double max) {
    final value = double.tryParse((raw ?? '').trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value < min || value > max) {
      return 'Introduce un valor entre $min y $max';
    }
    return null;
  }

  void _continue() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    widget.draft.latitude = double.parse(
      latitudeController.text.trim().replaceAll(',', '.'),
    );
    widget.draft.longitude = double.parse(
      longitudeController.text.trim().replaceAll(',', '.'),
    );
    widget.draft.locationDescription = referenceController.text.trim();
    widget.onContinue();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<SightingBloc, SightingState>(
    listenWhen: (_, current) => current is SightingLocationReady,
    listener: (context, state) {
      final position = (state as SightingLocationReady).position;
      latitudeController.text = position.latitude.toStringAsFixed(6);
      longitudeController.text = position.longitude.toStringAsFixed(6);
      setState(() {});
    },
    child: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(SpacingToken.m),
        children: [
          const Text(
            '¿Dónde viste a la mascota?',
            style: AppTextStyle.boldSubtitle,
          ),
          const SizedBox(height: SpacingToken.s),
          const Text(
            'Puedes usar el GPS ahora o introducir coordenadas reales manualmente. La referencia ayuda al dueño a reconocer el lugar.',
            style: AppTextStyle.regularCaption,
          ),
          const SizedBox(height: SpacingToken.l),
          BlocBuilder<SightingBloc, SightingState>(
            builder: (context, state) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: state is SightingLocationLoading
                      ? null
                      : () => context.read<SightingBloc>().add(
                          const GetDeviceLocation(),
                        ),
                  icon: state is SightingLocationLoading
                      ? const SizedBox.square(
                          dimension: SpacingToken.m,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surface,
                          ),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    state is SightingLocationLoading
                        ? 'Obteniendo ubicación...'
                        : 'Usar mi ubicación actual',
                  ),
                ),
                if (state is SightingFailure &&
                    state.kind == SightingFailureKind.location)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingToken.s),
                    child: Text(
                      state.message,
                      style: AppTextStyle.regularCaption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: SpacingToken.l),
          CustomTextField(
            label: 'Latitud',
            hint: 'Ej: -17.783333',
            controller: latitudeController,
            prefixIcon: Icons.explore_outlined,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            validator: (raw) => _coordinateValidator(raw, -90, 90),
          ),
          const SizedBox(height: SpacingToken.m),
          CustomTextField(
            label: 'Longitud',
            hint: 'Ej: -63.183333',
            controller: longitudeController,
            prefixIcon: Icons.explore_outlined,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            validator: (raw) => _coordinateValidator(raw, -180, 180),
          ),
          const SizedBox(height: SpacingToken.m),
          CustomTextField(
            label: 'Referencia del lugar',
            hint: 'Ej: Av. Banzer, cerca del parque',
            controller: referenceController,
            prefixIcon: Icons.location_on_outlined,
            validator: (raw) {
              final value = (raw ?? '').trim();
              if (value.isEmpty) return 'Introduce una referencia del lugar';
              if (value.length > 255) return 'Máximo 255 caracteres';
              return null;
            },
          ),
          const SizedBox(height: SpacingToken.s),
          const Text(
            'Si no tienes GPS, localiza el punto en Google Maps y copia sus coordenadas. No se asigna una ubicación aproximada automáticamente.',
            style: AppTextStyle.regularMicro,
          ),
          if (_hasValidCoordinates) ...[
            const SizedBox(height: SpacingToken.m),
            GoogleMapsLink(latitude: _latitude!, longitude: _longitude!),
          ],
          const SizedBox(height: SpacingToken.xL),
          ElevatedButton(onPressed: _continue, child: const Text('Continuar')),
        ],
      ),
    ),
  );
}
