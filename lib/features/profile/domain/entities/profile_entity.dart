import 'package:equatable/equatable.dart';
import '../../../../core/constants/cells_config.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final MinaCell cell;
  final String? bio;
  final String? avatarUrl;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isFollowedByMe;

  const ProfileEntity({
    required this.id, required this.name, required this.email,
    required this.cell, this.bio, this.avatarUrl,
    this.followersCount = 0, this.followingCount = 0,
    this.postsCount = 0, this.isFollowedByMe = false,
  });

  // cell toujours exclu de copyWith
  ProfileEntity copyWith({String? name, String? bio, String? avatarUrl,
    int? followersCount, int? followingCount, bool? isFollowedByMe}) =>
    ProfileEntity(
      id: id, email: email, cell: cell, postsCount: postsCount,
      name:           name           ?? this.name,
      bio:            bio            ?? this.bio,
      avatarUrl:      avatarUrl      ?? this.avatarUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowedByMe: isFollowedByMe ?? this.isFollowedByMe,
    );

  @override List<Object?> get props => [id];
}