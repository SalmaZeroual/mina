import 'dart:convert';
import '../../domain/entities/user_entity.dart';
import '../../../../core/constants/cells_config.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id, required super.name, required super.email,
    required super.cell, super.bio, super.avatarUrl,
    super.followersCount, super.followingCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:             json['id'] as String,
    name:           json['name'] as String,
    email:          json['email'] as String,
    cell:           MinaCell.fromString(json['cell_id'] as String),
    bio:            json['bio'] as String?,
    avatarUrl:      json['avatar_url'] as String?,
    followersCount: json['followers_count'] as int? ?? 0,
    followingCount: json['following_count'] as int? ?? 0,
  );

  factory UserModel.fromJsonString(String s) => UserModel.fromJson(jsonDecode(s));

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'cell_id': cell.id,
    'bio': bio, 'avatar_url': avatarUrl,
    'followers_count': followersCount, 'following_count': followingCount,
  };

  String toJsonString() => jsonEncode(toJson());
}