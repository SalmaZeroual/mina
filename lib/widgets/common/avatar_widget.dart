import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AvatarWidget extends StatelessWidget {
  final String initials;
  final double size;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    required this.initials,
    this.size = 44,
    this.backgroundColor,
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
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }
}
