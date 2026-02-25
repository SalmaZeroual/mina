import '../../domain/entities/post_entity.dart';
import '../../../../core/constants/cells_config.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id, required super.userId, required super.userName,
    super.userAvatarUrl, required super.userCell, required super.content,
    super.imageUrl, super.likesCount, super.commentsCount,
    super.isLikedByMe, required super.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> j) => PostModel(
    id:            j['id'] as String,
    userId:        j['user_id'] as String,
    userName:      j['user_name'] as String,
    userAvatarUrl: j['avatar_url'] as String?,
    userCell:      MinaCell.fromString(j['user_cell'] as String),
    content:       j['content'] as String,
    imageUrl:      j['image_url'] as String?,
    likesCount:    j['likes_count'] as int? ?? 0,
    commentsCount: j['comments_count'] as int? ?? 0,
    isLikedByMe:   (j['is_liked_by_me'] as int? ?? 0) == 1,
    createdAt:     DateTime.parse(j['created_at'] as String),
  );
}