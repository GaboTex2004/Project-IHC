import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/token_storage.dart';
import '../models/sighting_model.dart';

class SightingRemoteDataSource {
  final String baseUrl;
  final TokenStorage tokenStorage;
  SightingRemoteDataSource({String? baseUrl, required this.tokenStorage})
    : baseUrl = baseUrl ?? dotenv.env['BASE_URL'] ?? 'http://localhost:8000';

  Future<List<SightingModel>> getReportSightings(int reportId) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ServerException(
        message: 'Tu sesión expiró. Inicia sesión nuevamente.',
        statusCode: 401,
      );
    }
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/reports/$reportId/sightings/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw ServerException(
          message: _message(response),
          statusCode: response.statusCode,
        );
      }
      return (jsonDecode(response.body) as List)
          .map((item) => SightingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on TimeoutException {
      throw ServerException(
        message:
            'La solicitud tardó demasiado. Revisa tu conexión e inténtalo nuevamente.',
      );
    } on FormatException {
      throw ServerException(
        message: 'El servidor devolvió una respuesta inesperada.',
      );
    } on SocketException {
      throw ServerException(
        message: 'Sin conexión. Revisa tu red e inténtalo nuevamente.',
      );
    } on http.ClientException {
      throw ServerException(message: 'No se pudo conectar con el servidor.');
    } catch (_) {
      throw ServerException(
        message:
            'No se pudo consultar los avistamientos. Inténtalo nuevamente.',
      );
    }
  }

  Future<SightingModel> create({
    required int reportId,
    required double latitude,
    required double longitude,
    required String locationDescription,
    required DateTime sightingDateTime,
    required String description,
    List<int>? photoBytes,
    String? photoName,
  }) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ServerException(
        message: 'Tu sesión expiró. Inicia sesión nuevamente.',
        statusCode: 401,
      );
    }
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/api/sightings/'))
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['report_id'] = reportId.toString()
          ..fields['latitude'] = latitude.toStringAsFixed(6)
          ..fields['longitude'] = longitude.toStringAsFixed(6)
          ..fields['location_description'] = locationDescription
          ..fields['sighting_datetime'] = sightingDateTime
              .toUtc()
              .toIso8601String()
          ..fields['description'] = description;
    if (photoBytes != null && photoName != null) {
      request.files.add(
        http.MultipartFile.fromBytes('photo', photoBytes, filename: photoName),
      );
    }
    try {
      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 201) {
        return SightingModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      throw ServerException(
        message: _message(response),
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on TimeoutException {
      throw ServerException(
        message:
            'La solicitud tardó demasiado. Revisa tu conexión e inténtalo nuevamente.',
      );
    } on FormatException {
      throw ServerException(
        message: 'El servidor devolvió una respuesta inesperada.',
      );
    } on SocketException {
      throw ServerException(
        message: 'Sin conexión. Revisa tu red e inténtalo nuevamente.',
      );
    } on http.ClientException {
      throw ServerException(message: 'No se pudo conectar con el servidor.');
    } catch (_) {
      throw ServerException(
        message: 'No se pudo registrar el avistamiento. Inténtalo nuevamente.',
      );
    }
  }

  String _message(http.Response response) {
    if (response.statusCode == 401) {
      return 'Tu sesión expiró. Inicia sesión nuevamente.';
    }
    if (response.statusCode == 404) return 'El reporte ya no existe.';
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        if (body['error'] is String) return body['error'] as String;
        if (body['photo'] != null) {
          return 'No se pudo subir la fotografía. Elige otra imagen.';
        }
        for (final value in body.values) {
          if (value is List && value.isNotEmpty) return value.first.toString();
        }
      }
    } on FormatException {
      /* no JSON */
    }
    return 'No se pudo registrar el avistamiento. Inténtalo nuevamente.';
  }
}
