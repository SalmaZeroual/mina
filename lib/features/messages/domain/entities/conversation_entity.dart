import 'package:equatable/equatable.dart';
import '../../../../core/constants/cells_config.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final MinaCell otherUserCell;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ConversationEntity({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.otherUserCell,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  @override List<Object?> get props => [id];
}