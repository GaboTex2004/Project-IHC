import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Ajuste automático de host según la plataforma:
  // - Android Emulator: 10.0.2.2
  // - iOS Simulator / Web / Desktop: localhost
  // - Dispositivo físico: Cambiar por la IP local de tu PC (ej: 192.168.1.15)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  static String get lostPetsEndpoint => '$baseUrl/lost-pets/';
}
