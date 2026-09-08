import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateConversationUseCase {
  final ChatRepository repository;
  GetOrCreateConversationUseCase({required this.repository});
  Future<Either<Failure, Conversation>> call(int reportId) =>
      repository.getOrCreateConversation(reportId);
}
