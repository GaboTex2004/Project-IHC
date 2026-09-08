import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUseCase {
  final ChatRepository repository;
  GetConversationsUseCase({required this.repository});
  Future<Either<Failure, List<Conversation>>> call() =>
      repository.getConversations();
}
