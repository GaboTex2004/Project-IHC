import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/lost_pet_model.dart';

abstract class LostPetRemoteDataSource {
  /// Envía un reporte de mascota perdida mediante MultipartRequest a Django REST Framework
  Future<LostPetModel> reportLostPet({
    required LostPetModel pet,
    required File imageFile,
  });

  /// Obtiene la lista de reportes de mascotas perdidas
  Future<List<LostPetModel>> getLostPets();
}

class LostPetRemoteDataSourceImpl implements LostPetRemoteDataSource {
  final http.Client client;

  LostPetRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<LostPetModel> reportLostPet({
    required LostPetModel pet,
    required File imageFile,
  }) async {
    final uri = Uri.parse(ApiConstants.lostPetsEndpoint);
    
    // Crear petición multipart para enviar campos de texto + archivo de imagen
    final request = http.MultipartRequest('POST', uri);

    // 1. Agregar campos de texto requeridos por el modelo de Django
    request.fields.addAll(pet.toFormDataFields());

    // 2. Adjuntar el archivo de imagen en el campo 'photo' esperado por Django
    final multipartImage = await http.MultipartFile.fromPath(
      'photo',
      imageFile.path,
    );
    request.files.add(multipartImage);

    // 3. Enviar la petición
    try {
      final streamedResponse = await client.send(request).timeout(
            const Duration(seconds: 25),
          );
      final response = await http.Response.fromStream(streamedResponse);

      // Django REST Framework responde con HTTP 201 Created al crear un registro
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return LostPetModel.fromJson(decoded);
      } else {
        // Extraer mensaje de error del backend de Django
        String errorMessage = 'Error al registrar la mascota (${response.statusCode})';
        try {
          final errorBody = json.decode(utf8.decode(response.bodyBytes));
          if (errorBody is Map<String, dynamic>) {
            errorMessage = errorBody.entries
                .map((e) => '${e.key}: ${(e.value is List) ? e.value.join(", ") : e.value}')
                .join('\n');
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception(
        'No se pudo conectar con el servidor. Verifica que Django esté corriendo y la URL sea accesible.',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }

  @override
  Future<List<LostPetModel>> getLostPets() async {
    final uri = Uri.parse(ApiConstants.lostPetsEndpoint);
    
    try {
      final response = await client.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> decodedList = json.decode(utf8.decode(response.bodyBytes));
        return decodedList
            .map((item) => LostPetModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener mascotas perdidas (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No se pudo conectar con el servidor backend.');
    }
  }
}
