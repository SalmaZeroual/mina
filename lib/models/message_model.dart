class ConversationModel {
  final String id;
  final ParticipantModel participant;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isTyping;
  final String type; // 'friend' | 'service'
  final String? serviceTitle;

  ConversationModel({
    required this.id,
    required this.participant,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isTyping = false,
    this.type = 'friend',
    this.serviceTitle,
  });

  bool get isService => type == 'service';

  String get timeAgo {
    final diff = DateTime.now().difference(lastMessageAt);
    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${lastMessageAt.day}/${lastMessageAt.month}';
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participant: ParticipantModel.fromJson(json['participant'] ?? {}),
      lastMessage: json['last_message'] ?? '',
      lastMessageAt: DateTime.tryParse(json['last_message_at'] ?? '') ?? DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
      type: json['type'] as String? ?? 'friend',
      serviceTitle: json['service_title'] as String?,
    );
  }
}

class ParticipantModel {
  final String id;
  final String fullName;
  final String initials;
  final String? avatarUrl;
  final String title;
  final String? cell;
  final bool isOnline;

  ParticipantModel({
    required this.id,
    required this.fullName,
    required this.initials,
    this.avatarUrl,
    this.title = '',
    this.cell,
    this.isOnline = false,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      initials: json['initials'] ?? '',
      avatarUrl: json['avatar_url'],
      title: json['title'] ?? '',
      cell: json['cell'],
      isOnline: json['is_online'] ?? false,
    );
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final MessageType type;

  MessageModel({
    required this.id,
    required this.senderId,
    this.senderName = '',
    required this.content,
    required this.sentAt,
    this.isRead = false,
    this.type = MessageType.text,
  });

  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(sentAt);
    if (diff.inDays == 0) {
      return '${sentAt.hour.toString().padLeft(2, '0')}:${sentAt.minute.toString().padLeft(2, '0')}';
    }
    return '${sentAt.day}/${sentAt.month}';
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['sender']?['id'] ?? '',
      senderName: json['sender']?['full_name'] ?? '',
      content: json['content'],
      sentAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }
}

enum MessageType { text, image, file }