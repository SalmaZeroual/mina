import '../../../../core/constants/cells_config.dart';
import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.otherUserId,
    required super.otherUserName,
    super.otherUserAvatar,
    required super.otherUserCell,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> j) => ConversationModel(
    id:              j['id'] as String,
    otherUserId:     j['other_user_id'] as String,
    otherUserName:   j['other_user_name'] as String,
    otherUserAvatar: j['other_user_avatar'] as String?,
    otherUserCell:   MinaCell.fromString(j['other_user_cell'] as String? ?? 'entrepreneur'),
    lastMessage:     j['last_message'] as String?,
    lastMessageAt:   j['last_message_at'] != null
        ? DateTime.parse(j['last_message_at'] as String)
        : null,
    unreadCount:     (j['unread_count'] as num?)?.toInt() ?? 0,
  );
}