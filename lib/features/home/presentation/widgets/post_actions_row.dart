import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/post_entity.dart';
import '../../../../../core/constants/app_colors.dart';

class PostActionsRow extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onLike;
  const PostActionsRow({super.key, required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          _Action(
            icon: post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
            color: post.isLikedByMe ? AppColors.primary : AppColors.greyMuted,
            label: '${post.likesCount}',
            onTap: onLike,
          ),
          const SizedBox(width: 20),
          _Action(icon: Icons.chat_bubble_outline, label: '${post.commentsCount}', onTap: () {}),
          const SizedBox(width: 20),
          _Action(icon: Icons.share_outlined, label: 'Partager', onTap: () {}),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.greyMuted;
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, size: 17, color: c),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: c)),
      ]),
    );
  }
}
