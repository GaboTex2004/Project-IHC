import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../entities/conversation.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Conversation>>> getConversations();
  Future<Either<Failure, Conversation>> getOrCreateConversation(int reportId);
  Future<Either<Failure, List<ChatMessage>>> getMessages(int conversationId);
  Future<Either<Failure, ChatMessage>> sendMessage(
    int conversationId,
    String content,
  );
}
