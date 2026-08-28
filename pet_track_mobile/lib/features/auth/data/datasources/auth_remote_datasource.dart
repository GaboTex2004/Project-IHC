import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/auth_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/token_storage.dart';

class AuthRemoteDataSource {
  final String baseUrl;
  final TokenStorage _tokenStorage;

  AuthRemoteDataSource({String? baseUrl, TokenStorage? tokenStorage})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL'] ?? 'http://localhost:8000',
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<AuthModel> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final model = AuthModel.fromJson(jsonDecode(response.body));
      await _tokenStorage.saveTokens(access: model.access, refresh: model.refresh);
      return model;
    } else {
      final error = jsonDecode(response.body);
      throw ServerException(message: error['error'] ?? 'Error al iniciar sesión');
    }
  }

  Future<AuthModel> register(String username, String email, String password,
      {String firstName = '', String lastName = ''}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );

    if (response.statusCode == 201) {
      final model = AuthModel.fromJson(jsonDecode(response.body));
      await _tokenStorage.saveTokens(access: model.access, refresh: model.refresh);
      return model;
    } else {
      final error = jsonDecode(response.body);
      throw ServerException(message: error['error'] ?? 'Error al registrar usuario');
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }

  Future<String?> refreshToken() async {
    final refresh = await _tokenStorage.getRefreshToken();
    if (refresh == null) throw ServerException(message: 'No hay refresh token');

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccess = data['access'];
      await _tokenStorage.saveTokens(access: newAccess, refresh: refresh);
      return newAccess;
    } else {
      await _tokenStorage.clearTokens();
      throw ServerException(message: 'Sesión expirada');
    }
  }
}
