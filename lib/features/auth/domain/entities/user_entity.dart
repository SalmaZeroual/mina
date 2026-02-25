import 'package:equatable/equatable.dart';
import '../../../../core/constants/cells_config.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final MinaCell cell;
  final String? bio;
  final String? avatarUrl;
  final int followersCount;
  final int followingCount;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.cell,
    this.bio,
    this.avatarUrl,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  UserEntity copyWith({String? name, String? bio, String? avatarUrl}) => UserEntity(
    id: id, email: email, cell: cell,
    name:           name      ?? this.name,
    bio:            bio       ?? this.bio,
    avatarUrl:      avatarUrl ?? this.avatarUrl,
    followersCount: followersCount,
    followingCount: followingCount,
  );

  @override
  List<Object?> get props => [id, email, cell];
}