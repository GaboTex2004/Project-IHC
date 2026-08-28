import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/lost_pet_report_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/token_storage.dart';

class LostPetRemoteDataSource {
  final String baseUrl;
  final TokenStorage _tokenStorage;

  LostPetRemoteDataSource({String? baseUrl, TokenStorage? tokenStorage})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL'] ?? 'http://localhost:8000',
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<LostPetReportModel>> getReports() async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';
    final response = await http.get(
      Uri.parse('$baseUrl/api/reports/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => LostPetReportModel.fromJson(json)).toList();
    } else {
      throw ServerException(message: 'Error al obtener reportes');
    }
  }

  Future<LostPetReportModel> createReport({
    required String name,
    required List<int> photoBytes,
    required String photoName,
    required String characteristics,
    required String lastLocation,
    required String dateLost,
    required String contactInfo,
  }) async {
    final headers = await _authHeaders();

    final uri = Uri.parse('$baseUrl/api/reports/create/');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields['name'] = name
      ..fields['characteristics'] = characteristics
      ..fields['last_location'] = lastLocation
      ..fields['date_lost'] = dateLost
      ..fields['contact_info'] = contactInfo
      ..files.add(http.MultipartFile.fromBytes(
        'photo',
        photoBytes,
        filename: photoName,
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return LostPetReportModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ServerException(message: error['detail'] ?? error['error'] ?? 'Error al crear reporte');
    }
  }
}
