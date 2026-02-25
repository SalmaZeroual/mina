import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double size;

  const UserAvatar({super.key, this.avatarUrl, required this.name, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.surface2,
      backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
      child: avatarUrl == null
        ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: size * 0.42))
        : null,
    );
  }
}