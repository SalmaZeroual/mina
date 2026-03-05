import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';
import '../../services/post_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../common/avatar_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// POST CARD — fully interactive, professional
// ─────────────────────────────────────────────────────────────────────────────
class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onDeleted;

  const PostCard({super.key, required this.post, this.onDeleted});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late bool _liked;
  late int  _likesCount;
  late int  _commentsCount;

  bool _showComments    = false;
  bool _loadingComments = false;
  bool _sendingComment  = false;

  List<Map<String, dynamic>> _comments = [];
  final _commentCtrl = TextEditingController();
  final _commentFocus = FocusNode();

  // Bounce animation for like
  late final AnimationController _bounceCtrl;
  late final Animation<double>   _bounceAnim;

  @override
  void initState() {
    super.initState();
    _liked         = widget.post.isLiked;
    _likesCount    = widget.post.likesCount;
    _commentsCount = widget.post.commentsCount;

    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _bounceAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45)
          .chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.9)
          .chain(CurveTween(curve: Curves.easeIn)),  weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0)
          .chain(CurveTween(curve: Curves.elasticOut)), weight: 30),
    ]).animate(_bounceCtrl);
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  // ── Like ────────────────────────────────────────────────────────────────────
  Future<void> _toggleLike() async {
    HapticFeedback.lightImpact();
    _bounceCtrl.forward(from: 0);
    setState(() {
      _liked = !_liked;
      _likesCount += _liked ? 1 : -1;
    });
    try {
      await PostService().toggleLike(widget.post.id);
    } catch (_) {
      setState(() {
        _liked = !_liked;
        _likesCount += _liked ? 1 : -1;
      });
    }
  }

  // ── Comments ────────────────────────────────────────────────────────────────
  Future<void> _toggleComments({bool focusInput = false}) async {
    if (_showComments && !focusInput) {
      setState(() => _showComments = false);
      return;
    }
    if (!_showComments) {
      setState(() { _showComments = true; _loadingComments = true; });
      try {
        _comments = await PostService().getComments(widget.post.id);
      } catch (_) {}
      if (mounted) setState(() => _loadingComments = false);
    }
    if (focusInput) {
      Future.delayed(const Duration(milliseconds: 200),
          () => _commentFocus.requestFocus());
    }
  }

  Future<void> _postComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _sendingComment) return;
    setState(() => _sendingComment = true);
    try {
      final comment = await PostService().addComment(widget.post.id, text);
      _commentCtrl.clear();
      _commentFocus.unfocus();
      setState(() {
        _comments.add(comment);
        _commentsCount++;
      });
    } catch (_) {}
    if (mounted) setState(() => _sendingComment = false);
  }

  // ── Navigation ──────────────────────────────────────────────────────────────
  void _goToProfile(String userId) {
    final me = context.read<AuthProvider>().currentUser?.id;
    if (me == userId) {
      Navigator.pushNamed(context, AppRoutes.profile);
    } else {
      Navigator.pushNamed(context, AppRoutes.userProfile, arguments: userId);
    }
  }

  // ── Post menu ────────────────────────────────────────────────────────────────
  void _openMenu() {
    final me = context.read<AuthProvider>().currentUser?.id;
    final isOwner = me == widget.post.author.id;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MenuSheet(
        isOwner: isOwner,
        onDelete: isOwner ? () async {
          Navigator.pop(context);
          try {
            await PostService().deletePost(widget.post.id);
            widget.onDeleted?.call();
            if (mounted) _snack('Post deleted');
          } catch (_) {}
        } : null,
        onCopy: () {
          Navigator.pop(context);
          Clipboard.setData(ClipboardData(text: widget.post.content));
          _snack('Copied to clipboard');
        },
        onReport: () { Navigator.pop(context); _snack('Report submitted'); },
      ),
    );
  }

  // ── Repost ───────────────────────────────────────────────────────────────────
  void _openRepost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RepostSheet(post: widget.post),
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2)));

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final a = p.author;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ─ Header ─────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () => _goToProfile(a.id),
              child: Stack(children: [
                AvatarWidget(initials: a.initials, avatarUrl: a.avatarUrl, size: 46),
                if (a.isOnline)
                  Positioned(right: 1, bottom: 1,
                    child: Container(width: 12, height: 12,
                      decoration: BoxDecoration(color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                    )),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _goToProfile(a.id),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Flexible(
                      child: Text(a.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w800,
                              fontSize: 14.5, color: Color(0xFF0F172A))),
                    ),
                    if (a.cell.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _CellBadge(a.cell),
                    ],
                  ]),
                  if (a.title.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(a.title,
                        style: const TextStyle(color: Color(0xFF64748B),
                            fontSize: 12.5),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 1),
                  Text(p.timeAgo,
                      style: const TextStyle(color: Color(0xFF94A3B8),
                          fontSize: 11.5)),
                ]),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded,
                  color: Color(0xFF94A3B8), size: 22),
              onPressed: _openMenu,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ]),
        ),

        // ─ Content ────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: _ExpandableContent(text: p.content),
        ),

        // ─ Images ─────────────────────────────────────────────────────────────
        if (p.images.isNotEmpty) ...[
          _ImageGrid(images: p.images),
          const SizedBox(height: 8),
        ],

        // ─ Reaction bar ───────────────────────────────────────────────────────
        if (_likesCount > 0 || _commentsCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Row(children: [
              if (_likesCount > 0) ...[
                Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.thumb_up_rounded,
                      size: 11, color: Colors.white),
                ),
                const SizedBox(width: 5),
                Text('$_likesCount',
                    style: const TextStyle(fontSize: 12.5,
                        color: Color(0xFF64748B))),
              ],
              const Spacer(),
              if (_commentsCount > 0)
                GestureDetector(
                  onTap: () => _toggleComments(),
                  child: Text('$_commentsCount comment${_commentsCount > 1 ? "s" : ""}',
                      style: const TextStyle(fontSize: 12.5,
                          color: Color(0xFF64748B))),
                ),
            ]),
          ),

        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

        // ─ Action buttons ─────────────────────────────────────────────────────
        IntrinsicHeight(
          child: Row(children: [
            _ActionBtn(
              icon: _liked ? Icons.thumb_up_rounded : Icons.thumb_up_alt_outlined,
              label: 'Like',
              active: _liked,
              activeColor: AppTheme.primary,
              iconWidget: ScaleTransition(
                scale: _bounceAnim,
                child: Icon(
                  _liked ? Icons.thumb_up_rounded : Icons.thumb_up_alt_outlined,
                  size: 18,
                  color: _liked ? AppTheme.primary : const Color(0xFF64748B),
                ),
              ),
              onTap: _toggleLike,
            ),
            _vDivider(),
            _ActionBtn(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Comment',
              onTap: () => _toggleComments(focusInput: true),
            ),
            _vDivider(),
            _ActionBtn(
              icon: Icons.repeat_rounded,
              label: 'Repost',
              onTap: _openRepost,
            ),
            _vDivider(),
            _ActionBtn(
              icon: Icons.ios_share_rounded,
              label: 'Share',
              onTap: () {
                Clipboard.setData(ClipboardData(text: p.content));
                _snack('Post copied');
              },
            ),
          ]),
        ),

        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

        // ─ Comments ───────────────────────────────────────────────────────────
        if (_showComments)
          _CommentsPanel(
            comments: _comments,
            loading: _loadingComments,
            sending: _sendingComment,
            controller: _commentCtrl,
            focusNode: _commentFocus,
            onSend: _postComment,
            onProfileTap: _goToProfile,
            myInitials: context.read<AuthProvider>().currentUser?.initials ?? '?',
            myAvatar: context.read<AuthProvider>().currentUser?.avatarUrl,
          ),
      ]),
    );
  }

  Widget _vDivider() => Container(
      width: 1, height: 40, color: const Color(0xFFF1F5F9));
}

// ─────────────────────────────────────────────────────────────────────────────
// Cell badge
// ─────────────────────────────────────────────────────────────────────────────
class _CellBadge extends StatelessWidget {
  final String cell;
  const _CellBadge(this.cell);

  Color get _color {
    const m = {
      'Web Development': Color(0xFF6366F1), 'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6),        'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6),       'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981),         'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444),
    };
    return m[cell] ?? AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
        color: _color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.2))),
    child: Text(cell,
        style: TextStyle(fontSize: 9.5, color: _color,
            fontWeight: FontWeight.w700, letterSpacing: 0.2)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Action button
// ─────────────────────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final Widget? iconWidget;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon, required this.label,
    this.active = false,
    this.activeColor = AppTheme.primary,
    this.iconWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : const Color(0xFF64748B);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          color: Colors.transparent,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            iconWidget ??
                Icon(icon, size: 18, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(fontSize: 12.5,
                    fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expandable text
// ─────────────────────────────────────────────────────────────────────────────
class _ExpandableContent extends StatefulWidget {
  final String text;
  const _ExpandableContent({required this.text});
  @override
  State<_ExpandableContent> createState() => _ExpandableContentState();
}

class _ExpandableContentState extends State<_ExpandableContent> {
  bool _expanded = false;
  static const _maxChars = 240;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.text.length > _maxChars;
    final shown  = isLong && !_expanded
        ? widget.text.substring(0, _maxChars)
        : widget.text;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text.rich(TextSpan(
        text: shown,
        style: const TextStyle(fontSize: 14.5, height: 1.6,
            color: Color(0xFF1E293B)),
        children: isLong && !_expanded ? [
          TextSpan(
            text: '... ',
            style: const TextStyle(color: Color(0xFF1E293B)),
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: const Text('See more',
                  style: TextStyle(color: AppTheme.primary,
                      fontWeight: FontWeight.w700, fontSize: 14.5)),
            ),
          ),
        ] : [],
      )),
      if (isLong && _expanded) ...[
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _expanded = false),
          child: const Text('Show less',
              style: TextStyle(color: AppTheme.primary,
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image grid
// ─────────────────────────────────────────────────────────────────────────────
class _ImageGrid extends StatelessWidget {
  final List<String> images;
  const _ImageGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) return _img(images[0], 240);
    if (images.length == 2) return Row(children: [
      Expanded(child: _img(images[0], 190)),
      const SizedBox(width: 2),
      Expanded(child: _img(images[1], 190)),
    ]);
    return Column(children: [
      _img(images[0], 180),
      const SizedBox(height: 2),
      Row(children: [
        Expanded(child: _img(images[1], 130)),
        const SizedBox(width: 2),
        Expanded(child: _img(images[2], 130)),
      ]),
    ]);
  }

  Widget _img(String url, double h) => SizedBox(
    height: h, width: double.infinity,
    child: Image.network(url, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFF0F2F5),
            child: const Icon(Icons.image_outlined,
                color: Color(0xFF94A3B8), size: 32))),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Comments panel
// ─────────────────────────────────────────────────────────────────────────────
class _CommentsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> comments;
  final bool loading, sending;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final ValueChanged<String> onProfileTap;
  final String myInitials;
  final String? myAvatar;

  const _CommentsPanel({
    required this.comments, required this.loading,
    required this.sending, required this.controller,
    required this.focusNode, required this.onSend,
    required this.onProfileTap, required this.myInitials,
    this.myAvatar,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Comments list
      if (loading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppTheme.primary))),
        )
      else ...[
        if (comments.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text('No comments yet — be the first!',
                style: TextStyle(color: Color(0xFF94A3B8),
                    fontSize: 13, fontStyle: FontStyle.italic)),
          ),
        ...comments.map((c) => _CommentBubble(
            comment: c, onProfileTap: onProfileTap)),
      ],

      // Input row
      Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          AvatarWidget(initials: myInitials, avatarUrl: myAvatar, size: 34),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 13.5),
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 38, height: 38,
              decoration: BoxDecoration(
                  color: sending
                      ? AppTheme.primary.withOpacity(0.5)
                      : AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 8, offset: const Offset(0, 3))]),
              child: sending
                  ? const Padding(padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded,
                      size: 16, color: Colors.white),
            ),
          ),
        ]),
      ),
    ],
  );
}

class _CommentBubble extends StatelessWidget {
  final Map<String, dynamic> comment;
  final ValueChanged<String> onProfileTap;
  const _CommentBubble({required this.comment, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final author  = (comment['author'] as Map<String, dynamic>?) ?? {};
    final name    = author['full_name']  as String? ?? '';
    final initials= author['initials']   as String? ?? '?';
    final avatar  = author['avatar_url'] as String?;
    final content = comment['content']   as String? ?? '';
    final authorId= author['id']         as String? ?? '';
    final dt      = DateTime.tryParse(comment['created_at'] as String? ?? '');
    final ago     = dt != null ? _timeAgo(dt) : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => onProfileTap(authorId),
          child: AvatarWidget(initials: initials, avatarUrl: avatar, size: 33),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                )),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              GestureDetector(
                onTap: () => onProfileTap(authorId),
                child: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 12.5, color: Color(0xFF0F172A))),
              ),
              const SizedBox(height: 3),
              Text(content,
                  style: const TextStyle(fontSize: 13.5, height: 1.45,
                      color: Color(0xFF334155))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 3, bottom: 4),
            child: Text(ago,
                style: const TextStyle(fontSize: 11,
                    color: Color(0xFF94A3B8))),
          ),
        ]),
        ),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours   < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Post menu sheet
// ─────────────────────────────────────────────────────────────────────────────
class _MenuSheet extends StatelessWidget {
  final bool isOwner;
  final VoidCallback? onDelete;
  final VoidCallback onCopy;
  final VoidCallback onReport;
  const _MenuSheet({required this.isOwner, this.onDelete,
      required this.onCopy, required this.onReport});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 12),
      Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 8),
      _tile(context, Icons.copy_outlined,
          'Copy text', const Color(0xFF374151), onCopy),
      if (isOwner)
        _tile(context, Icons.delete_outline_rounded,
            'Delete post', Colors.red, onDelete ?? () {}),
      if (!isOwner) ...[
        _tile(context, Icons.flag_outlined,
            'Report post', const Color(0xFF374151), onReport),
        _tile(context, Icons.person_off_outlined,
            'Hide from feed', const Color(0xFF374151),
            () => Navigator.pop(context)),
      ],
    ]),
  );

  Widget _tile(BuildContext ctx, IconData icon, String label, Color color,
      VoidCallback onTap) =>
      ListTile(
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 19, color: color),
        ),
        title: Text(label, style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14, color: color)),
        onTap: onTap, dense: true,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Repost sheet
// ─────────────────────────────────────────────────────────────────────────────
class _RepostSheet extends StatefulWidget {
  final PostModel post;
  const _RepostSheet({required this.post});
  @override
  State<_RepostSheet> createState() => _RepostSheetState();
}

class _RepostSheetState extends State<_RepostSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final quote   = _ctrl.text.trim();
      final original = widget.post.content.length > 200
          ? '${widget.post.content.substring(0, 200)}...'
          : widget.post.content;
      final content = [
        if (quote.isNotEmpty) quote,
        '🔁 Reposted from ${widget.post.author.fullName}:',
        '"$original"',
      ].join('\n\n');
      await PostService().createPost(content);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Reposted!'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ));
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    padding: EdgeInsets.fromLTRB(
        20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 28),
    child: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 18),
        Row(children: const [
          Icon(Icons.repeat_rounded, color: AppTheme.primary, size: 20),
          SizedBox(width: 8),
          Text('Repost', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        ]),
        const SizedBox(height: 14),

        // Original preview
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              AvatarWidget(
                  initials: widget.post.author.initials,
                  avatarUrl: widget.post.author.avatarUrl,
                  size: 30),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.post.author.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 13)),
                Text(widget.post.timeAgo,
                    style: const TextStyle(color: Color(0xFF94A3B8),
                        fontSize: 11)),
              ]),
            ]),
            const SizedBox(height: 8),
            Text(
              widget.post.content.length > 160
                  ? '${widget.post.content.substring(0, 160)}...'
                  : widget.post.content,
              style: const TextStyle(fontSize: 13.5,
                  color: Color(0xFF475569), height: 1.45),
            ),
          ]),
        ),

        const SizedBox(height: 12),
        TextField(
          controller: _ctrl,
          autofocus: true,
          maxLines: 4,
          minLines: 2,
          decoration: InputDecoration(
            hintText: 'Add your thoughts... (optional)',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: AppTheme.primary, width: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.repeat_rounded, size: 19),
            label: const Text('Repost now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
          ),
        ),
      ]),
    ),
  );
}