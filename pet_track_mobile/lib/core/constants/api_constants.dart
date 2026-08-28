import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
  }

  static String get lostPetsEndpoint => '$baseUrl/api/lost-pets/';
  static String get authLoginEndpoint => '$baseUrl/api/auth/login/';
  static String get authRegisterEndpoint => '$baseUrl/api/auth/register/';
  static String get authProfileEndpoint => '$baseUrl/api/auth/profile/';
  static String get reportsEndpoint => '$baseUrl/api/reports/';
}
