import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/token_storage.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

class ChatRemoteDataSource {
  final String baseUrl;
  final TokenStorage tokenStorage;
  ChatRemoteDataSource({String? baseUrl, required this.tokenStorage})
    : baseUrl = baseUrl ?? dotenv.env['BASE_URL'] ?? 'http://localhost:8000';

  Future<Map<String, String>> _headers() async {
    final token = await tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ConversationModel>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/conversations/'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw _exception(response, 'Error al obtener conversaciones');
    }
    return (jsonDecode(response.body) as List)
        .map((item) => ConversationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ConversationModel> getOrCreateConversation(int reportId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/conversations/'),
      headers: await _headers(),
      body: jsonEncode({'report_id': reportId}),
    );
    if (response.statusCode != 200) {
      throw _exception(response, 'No se pudo abrir la conversación');
    }
    return ConversationModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<ChatMessageModel>> getMessages(int conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/conversations/$conversationId/messages/'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw _exception(response, 'Error al obtener mensajes');
    }
    return (jsonDecode(response.body) as List)
        .map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessageModel> sendMessage(
    int conversationId,
    String content,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/conversations/$conversationId/messages/'),
      headers: await _headers(),
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode != 201) {
      throw _exception(response, 'No se pudo enviar el mensaje');
    }
    return ChatMessageModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  ServerException _exception(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        return ServerException(
          message: (body['error'] ?? body['detail'] ?? fallback).toString(),
          statusCode: response.statusCode,
        );
      }
    } on FormatException {
      /* respuesta no JSON */
    }
    return ServerException(message: fallback, statusCode: response.statusCode);
  }
}
