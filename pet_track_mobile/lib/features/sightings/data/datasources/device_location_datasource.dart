import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/device_position.dart';

class DeviceLocationException implements Exception {
  final String message;
  const DeviceLocationException(this.message);
}

class DeviceLocationDataSource {
  Future<DevicePosition> getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const DeviceLocationException(
          'El GPS está desactivado. Actívalo o introduce las coordenadas manualmente.',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const DeviceLocationException(
          'No se concedió el permiso de ubicación. Puedes introducir las coordenadas manualmente.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        throw const DeviceLocationException(
          'El permiso está bloqueado. Actívalo desde Ajustes o introduce las coordenadas manualmente.',
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return DevicePosition(position.latitude, position.longitude);
    } on DeviceLocationException {
      rethrow;
    } on TimeoutException {
      throw const DeviceLocationException(
        'El GPS tardó demasiado. Inténtalo de nuevo o introduce las coordenadas manualmente.',
      );
    } on LocationServiceDisabledException {
      throw const DeviceLocationException(
        'El GPS está desactivado. Actívalo o introduce las coordenadas manualmente.',
      );
    } catch (_) {
      throw const DeviceLocationException(
        'No se pudo obtener la ubicación. Puedes introducir las coordenadas manualmente.',
      );
    }
  }
}
