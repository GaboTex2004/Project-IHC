import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  ChatRepositoryImpl({required this.remoteDataSource});
  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final values = await remoteDataSource.getConversations();
      return Right(
        values.map((e) => e.toEntity(remoteDataSource.baseUrl)).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getOrCreateConversation(
    int reportId,
  ) async {
    try {
      return Right(
        (await remoteDataSource.getOrCreateConversation(
          reportId,
        )).toEntity(remoteDataSource.baseUrl),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    int conversationId,
  ) async {
    try {
      final values = await remoteDataSource.getMessages(conversationId);
      return Right(values.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(
    int conversationId,
    String content,
  ) async {
    try {
      return Right(
        (await remoteDataSource.sendMessage(
          conversationId,
          content,
        )).toEntity(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
