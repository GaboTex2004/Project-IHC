import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
    id,
    conversationId,
    senderId,
    senderName,
    content,
    createdAt,
  ];
}
