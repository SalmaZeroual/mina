import 'user_model.dart';

class PostModel {
  final String id;
  final UserModel author;
  final String content;
  final List<String> images;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final bool isLiked;

  PostModel({
    required this.id,
    required this.author,
    required this.content,
    this.images = const [],
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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      author: UserModel.fromJson(json['author']),
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isLiked: json['is_liked'] ?? false,
    );
  }
}