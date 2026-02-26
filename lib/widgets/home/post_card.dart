import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';
import '../common/avatar_widget.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onLike;

  const PostCard({super.key, required this.post, this.onLike});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likes = widget.post.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final author = post.author;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(initials: author.initials),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(author.title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text(post.timeAgo, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_horiz, color: AppTheme.textSecondary), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 10),
          Text(post.content, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              _ActionButton(
                icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: '$_likes',
                color: _isLiked ? AppTheme.primary : AppTheme.textSecondary,
                onTap: () {
                  setState(() {
                    _isLiked = !_isLiked;
                    _likes += _isLiked ? 1 : -1;
                  });
                  widget.onLike?.call();
                },
              ),
              const SizedBox(width: 20),
              _ActionButton(icon: Icons.chat_bubble_outline, label: '${post.commentsCount}', onTap: () {}),
              const SizedBox(width: 20),
              _ActionButton(icon: Icons.share_outlined, label: 'Share', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, this.color = AppTheme.textSecondary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}
