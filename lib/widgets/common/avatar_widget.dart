import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AvatarWidget extends StatelessWidget {
  final String initials;
  final double size;
  final Color? backgroundColor;
  final String? avatarUrl;

  const AvatarWidget({
    super.key,
    required this.initials,
    this.size = 44,
    this.backgroundColor,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primary,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initials(),
            )
          : _initials(),
    );
  }

  Widget _initials() => Center(
    child: Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: size * 0.35,
      ),
    ),
  );
}