import 'package:equatable/equatable.dart';
import '../../../../core/constants/cells_config.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final MinaCell userCell;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  const PostEntity({
    required this.id, required this.userId, required this.userName,
    this.userAvatarUrl, required this.userCell, required this.content,
    this.imageUrl, this.likesCount = 0, this.commentsCount = 0,
    this.isLikedByMe = false, required this.createdAt,
  });

  PostEntity copyWith({int? likesCount, int? commentsCount, bool? isLikedByMe}) => PostEntity(
    id: id, userId: userId, userName: userName, userAvatarUrl: userAvatarUrl,
    userCell: userCell, content: content, imageUrl: imageUrl, createdAt: createdAt,
    likesCount:    likesCount    ?? this.likesCount,
    commentsCount: commentsCount ?? this.commentsCount,
    isLikedByMe:   isLikedByMe   ?? this.isLikedByMe,
  );

  @override List<Object?> get props => [id];
}