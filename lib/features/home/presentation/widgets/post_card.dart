import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/post_entity.dart';
import '../providers/feed_provider.dart';
import '../../../../../shared/widgets/cell_tag.dart';
import '../../../../../shared/widgets/user_avatar.dart';
import 'post_actions_row.dart';
import '../../../../../core/constants/app_colors.dart';

class PostCard extends ConsumerWidget {
  final PostEntity post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(children: [
              UserAvatar(avatarUrl: post.userAvatarUrl, name: post.userName),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.userName, style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.white)),
                  const SizedBox(height: 3),
                  Row(children: [
                    CellTag(cell: post.userCell, small: true),
                    const SizedBox(width: 6),
                    Text(_ago(post.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.greyMuted)),
                  ]),
                ],
              )),
              Icon(Icons.more_horiz, color: AppColors.greyLight, size: 18),
            ]),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(post.content, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.white)),
          ),

          // Image
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(imageUrl: post.imageUrl!, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(height: 160, color: AppColors.surface2),
                  errorWidget: (_, __, ___) => Container(height: 160, color: AppColors.surface2)),
              ),
            ),

          const SizedBox(height: 4),
          const Divider(),
          PostActionsRow(
            post: post,
            onLike: () => ref.read(feedProvider.notifier).toggleLike(post.id),
          ),
        ],
      ),
    );
  }

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return 'il y a ${d.inMinutes}min';
    if (d.inHours < 24)   return 'il y a ${d.inHours}h';
    return 'il y a ${d.inDays}j';
  }
}