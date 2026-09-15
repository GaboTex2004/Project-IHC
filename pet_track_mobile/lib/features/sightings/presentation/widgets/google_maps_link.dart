import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Uri googleMapsUri(double latitude, double longitude) => Uri.https(
  'www.google.com',
  '/maps/search/',
  {'api': '1', 'query': '$latitude,$longitude'},
);

class GoogleMapsLink extends StatelessWidget {
  final double latitude;
  final double longitude;
  const GoogleMapsLink({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  Future<void> _open(BuildContext context) async {
    try {
      final opened = await launchUrl(
        googleMapsUri(latitude, longitude),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => _open(context),
    icon: const Icon(Icons.map_outlined),
    label: const Text('Ver en Google Maps'),
  );
}
