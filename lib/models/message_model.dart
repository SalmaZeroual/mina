class ConversationModel {
  final String id;
  final ParticipantModel participant;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.participant,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(lastMessageAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return 'Yesterday';
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participant: ParticipantModel.fromJson(json['participant'] ?? {}),
      lastMessage: json['last_message'] ?? '',
      lastMessageAt: DateTime.tryParse(json['last_message_at'] ?? '') ?? DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class ParticipantModel {
  final String id;
  final String fullName;
  final String initials;
  final String? avatarUrl;
  final String title;
  final bool isOnline;

  ParticipantModel({
    required this.id,
    required this.fullName,
    required this.initials,
    this.avatarUrl,
    this.title = '',
    this.isOnline = false,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      initials: json['initials'] ?? '',
      avatarUrl: json['avatar_url'],
      title: json['title'] ?? '',
      isOnline: json['is_online'] ?? false,
    );
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['sender']?['id'] ?? '',
      content: json['content'],
      sentAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }
}