import '../../domain/entities/chat_message.dart';

class ChatMessageModel {
  final Map<String, dynamic> json;
  ChatMessageModel.fromJson(this.json);
  ChatMessage toEntity() => ChatMessage(
    id: json['id'] as int,
    conversationId: json['conversation_id'] as int,
    senderId: json['sender_id'] as int,
    senderName: json['sender_name'].toString(),
    content: json['content'].toString(),
    createdAt: DateTime.parse(json['created_at'].toString()),
  );
}
