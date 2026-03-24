class ConversationModel {
  final String id;
  final ParticipantModel participant;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isTyping;
  final String type;
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
      isTyping: json['is_typing'] == true,
    );
  }

  ConversationModel copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isTyping,
  }) {
    return ConversationModel(
      id: id,
      participant: participant,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isTyping: isTyping ?? this.isTyping,
      type: type,
      serviceTitle: serviceTitle,
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
      isOnline: json['is_online'] == true || json['is_online'] == 1,
    );
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final String? mediaUrl;
  final MessageType type;
  final String? replyToId;
  final String? replyToContent;
  final String? replyToSender;
  final Map<String, List<String>> reactions; // emoji -> [userId, ...]
  final DateTime sentAt;
  final bool isRead;
  final bool isDeleted;

  MessageModel({
    required this.id,
    required this.senderId,
    this.senderName = '',
    this.senderAvatar,
    required this.content,
    this.mediaUrl,
    this.type = MessageType.text,
    this.replyToId,
    this.replyToContent,
    this.replyToSender,
    this.reactions = const {},
    required this.sentAt,
    this.isRead = false,
    this.isDeleted = false,
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
    // Parse reactions: { "👍": ["uid1", "uid2"] }
    Map<String, List<String>> reactions = {};
    final rawReactions = json['reactions'];
    if (rawReactions is Map) {
      rawReactions.forEach((emoji, users) {
        if (users is List) {
          reactions[emoji as String] = users.map((u) => u.toString()).toList();
        }
      });
    }

    return MessageModel(
      id: json['id'],
      senderId: json['sender']?['id'] ?? '',
      senderName: json['sender']?['full_name'] ?? '',
      senderAvatar: json['sender']?['avatar_url'],
      content: json['content'] ?? '',
      mediaUrl: json['media_url'],
      type: json['message_type'] == 'image' ? MessageType.image : MessageType.text,
      replyToId: json['reply_to_id'],
      replyToContent: json['reply_to_content'],
      replyToSender: json['reply_to_sender'],
      reactions: reactions,
      sentAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      isDeleted: json['is_deleted'] == true || json['is_deleted'] == 1,
    );
  }

  MessageModel copyWith({bool? isRead, Map<String, List<String>>? reactions}) {
    return MessageModel(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content,
      mediaUrl: mediaUrl,
      type: type,
      replyToId: replyToId,
      replyToContent: replyToContent,
      replyToSender: replyToSender,
      reactions: reactions ?? this.reactions,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted,
    );
  }
}

enum MessageType { text, image }