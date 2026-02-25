import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_remote_datasource.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource _remote;
  const MessageRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() async {
    try {
      return Right(await _remote.getConversations());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> startConversation({
    required String userId,
  }) async {
    try {
      return Right(await _remote.startConversation(userId: userId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String conversationId,
    int page = 1,
  }) async {
    try {
      return Right(await _remote.getMessages(
        conversationId: conversationId,
        page: page,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      return Right(await _remote.sendMessage(
        conversationId: conversationId,
        content: content,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}