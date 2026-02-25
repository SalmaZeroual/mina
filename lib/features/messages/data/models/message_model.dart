import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    super.senderAvatar,
    required super.content,
    super.isRead,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
    id:             j['id'] as String,
    conversationId: j['conversation_id'] as String? ?? '',
    senderId:       j['sender_id'] as String,
    senderName:     j['sender_name'] as String,
    senderAvatar:   j['avatar_url'] as String?,
    content:        j['content'] as String,
    isRead:         (j['is_read'] == 1 || j['is_read'] == true),
    createdAt:      DateTime.parse(j['created_at'] as String),
  );
}