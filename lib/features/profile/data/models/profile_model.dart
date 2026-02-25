import '../../../../core/constants/cells_config.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.cell,
    super.bio,
    super.avatarUrl,
    super.followersCount,
    super.followingCount,
    super.postsCount,
    super.isFollowedByMe,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> j) => ProfileModel(
    id:             j['id'] as String,
    name:           j['name'] as String,
    email:          j['email'] as String? ?? '',
    cell:           MinaCell.fromString(j['cell_id'] as String? ?? 'entrepreneur'),
    bio:            j['bio'] as String?,
    avatarUrl:      j['avatar_url'] as String?,
    followersCount: (j['followers_count'] as num?)?.toInt() ?? 0,
    followingCount: (j['following_count'] as num?)?.toInt() ?? 0,
    postsCount:     (j['posts_count'] as num?)?.toInt() ?? 0,
    isFollowedByMe: (j['is_followed_by_me'] == 1 || j['is_followed_by_me'] == true),
  );
}