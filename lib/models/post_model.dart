import 'user_model.dart';

class PostModel {
  final String id;
  final UserModel author;
  final String content;
  final List<String>? images;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final bool isLiked;

  PostModel({
    required this.id,
    required this.author,
    required this.content,
    this.images,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.isLiked = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static List<PostModel> get mocks => [
    PostModel(
      id: 'p1',
      author: UserModel(
        id: 'u2', fullName: 'Sarah Johnson', email: 'sarah@ex.com',
        initials: 'SJ', cell: 'Web Development', title: 'Flutter Developer',
        joinedAt: DateTime(2023),
      ),
      content: 'Just shipped a new feature for our mobile app! The team worked incredibly hard on this. Grateful for everyone\'s dedication. 🚀',
      likesCount: 42,
      commentsCount: 8,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PostModel(
      id: 'p2',
      author: UserModel(
        id: 'u3', fullName: 'Michael Chen', email: 'michael@ex.com',
        initials: 'MC', cell: 'Web Development', title: 'React Developer',
        joinedAt: DateTime(2023),
      ),
      content: 'Looking for recommendations on state management libraries for large-scale React applications. What\'s your go-to solution?',
      likesCount: 28,
      commentsCount: 15,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    PostModel(
      id: 'p3',
      author: UserModel(
        id: 'u4', fullName: 'Emma Wilson', email: 'emma@ex.com',
        initials: 'EW', cell: 'Design', title: 'UI/UX Designer',
        joinedAt: DateTime(2023),
      ),
      content: 'Excited to share that I\'m speaking at the Web Dev Conference next month! Topic: Modern Design Systems for React Applications.',
      likesCount: 67,
      commentsCount: 12,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    PostModel(
      id: 'p4',
      author: UserModel(
        id: 'u5', fullName: 'David Martinez', email: 'david@ex.com',
        initials: 'DM', cell: 'Web Development', title: 'Backend Developer',
        joinedAt: DateTime(2023),
      ),
      content: 'The API documentation is ready for review. Built with Node.js and Express — performance improved by 40%. Check it out and share your feedback! 💪',
      likesCount: 34,
      commentsCount: 7,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];
}
