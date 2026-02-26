import 'user_model.dart';

class ConversationModel {
  final String id;
  final UserModel participant;
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

  static List<ConversationModel> get mocks => [
    ConversationModel(
      id: 'c1',
      participant: UserModel(id: 'u2', fullName: 'Sarah Johnson', email: 'sarah@ex.com', initials: 'SJ', cell: 'Web Development', title: 'Flutter Developer', joinedAt: DateTime(2023), isOnline: true),
      lastMessage: 'Sounds great! Let\'s schedule it for next week.',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 2)),
      unreadCount: 2,
    ),
    ConversationModel(
      id: 'c2',
      participant: UserModel(id: 'u3', fullName: 'Michael Chen', email: 'michael@ex.com', initials: 'MC', cell: 'Web Development', title: 'React Developer', joinedAt: DateTime(2023), isOnline: true),
      lastMessage: 'I\'d recommend Redux Toolkit for that use case.',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ConversationModel(
      id: 'c3',
      participant: UserModel(id: 'u4', fullName: 'Emma Wilson', email: 'emma@ex.com', initials: 'EW', cell: 'Design', title: 'UI/UX Designer', joinedAt: DateTime(2023)),
      lastMessage: 'Thank you! Really appreciate the support 🙏',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ConversationModel(
      id: 'c4',
      participant: UserModel(id: 'u5', fullName: 'David Martinez', email: 'david@ex.com', initials: 'DM', cell: 'Web Development', title: 'Backend Developer', joinedAt: DateTime(2023)),
      lastMessage: 'The API documentation is ready for review.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
    ),
  ];
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

  static List<MessageModel> getMocksForConversation(String conversationId) {
    return [
      MessageModel(id: 'm1', senderId: 'u2', content: 'Hey! I saw your post about React state management.', sentAt: DateTime.now().subtract(const Duration(hours: 2))),
      MessageModel(id: 'm2', senderId: 'user_1', content: 'Yes! I\'ve been exploring different options. What do you use?', sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50))),
      MessageModel(id: 'm3', senderId: 'u2', content: 'I\'ve been using Zustand lately. It\'s much simpler than Redux!', sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45))),
      MessageModel(id: 'm4', senderId: 'user_1', content: 'That\'s interesting. How does it handle complex state trees?', sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30))),
      MessageModel(id: 'm5', senderId: 'u2', content: 'Really well actually. And the bundle size is tiny. Let me share some examples.', sentAt: DateTime.now().subtract(const Duration(minutes: 20))),
      MessageModel(id: 'm6', senderId: 'u2', content: 'Sounds great! Let\'s schedule it for next week.', sentAt: DateTime.now().subtract(const Duration(minutes: 2))),
    ];
  }
}
