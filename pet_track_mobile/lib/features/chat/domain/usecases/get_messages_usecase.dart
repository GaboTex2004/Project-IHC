import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;
  GetMessagesUseCase({required this.repository});
  Future<Either<Failure, List<ChatMessage>>> call(int conversationId) =>
      repository.getMessages(conversationId);
}
