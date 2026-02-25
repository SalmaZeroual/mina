import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class MessageRepository {
  Future<Either<Failure, List<ConversationEntity>>> getConversations();

  Future<Either<Failure, ConversationEntity>> startConversation({
    required String userId,
  });

  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String conversationId,
    int page = 1,
  });

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
  });
}