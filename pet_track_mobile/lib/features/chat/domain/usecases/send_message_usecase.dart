import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase({required this.repository});
  Future<Either<Failure, ChatMessage>> call(
    int conversationId,
    String content,
  ) => repository.sendMessage(conversationId, content);
}
