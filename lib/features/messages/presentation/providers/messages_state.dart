import 'package:flutter/foundation.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

// ─── Conversations ────────────────────────────────────────────────────────────

@immutable
abstract class ConversationsState {
  const ConversationsState();
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  final List<ConversationEntity> conversations;
  const ConversationsLoaded({required this.conversations});
}

class ConversationsError extends ConversationsState {
  final String message;
  const ConversationsError(this.message);
}

// ─── Chat ─────────────────────────────────────────────────────────────────────

@immutable
abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final bool someoneTyping;
  final String typingName;

  const ChatLoaded({
    required this.messages,
    this.someoneTyping = false,
    this.typingName = '',
  });

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    bool? someoneTyping,
    String? typingName,
  }) =>
      ChatLoaded(
        messages:      messages      ?? this.messages,
        someoneTyping: someoneTyping ?? this.someoneTyping,
        typingName:    typingName    ?? this.typingName,
      );
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}