import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';
import '../../services/post_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../widgets/common/avatar_widget.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel post;
  const CommentsScreen({super.key, required this.post});
  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _svc        = PostService();
  final _inputCtrl  = TextEditingController();
  final _focusNode  = FocusNode();

  List<_CommentItem> _comments = [];
  bool _loading = true;
  bool _sending = false;
  _CommentItem? _replyingTo;

  // Post like state
  late bool _postLiked;
  late int  _postLikes;

  @override
  void initState() {
    super.initState();
    _postLiked = widget.post.isLiked;
    _postLikes = widget.post.likesCount;
    _loadComments();
  }

  @override
  void dispose() { _inputCtrl.dispose(); _focusNode.dispose(); super.dispose(); }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final raw = await _svc.getComments(widget.post.id);
      _comments = raw.map((c) => _CommentItem.fromMap(c)).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      if (_replyingTo != null) {
        final reply = await _svc.replyComment(_replyingTo!.id, text);
        final newReply = _CommentItem.fromMap(reply);
        final idx = _comments.indexWhere((c) => c.id == _replyingTo!.id);
        if (idx != -1) setState(() { _comments[idx] = _comments[idx].withReply(newReply); _replyingTo = null; });
      } else {
        final comment = await _svc.addComment(widget.post.id, text);
        setState(() => _comments.insert(0, _CommentItem.fromMap(comment)));
      }
      _inputCtrl.clear(); _focusNode.unfocus();
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _togglePostLike() async {
    HapticFeedback.lightImpact();
    setState(() { _postLiked = !_postLiked; _postLikes += _postLiked ? 1 : -1; });
    try { await _svc.toggleLike(widget.post.id); }
    catch (_) { setState(() { _postLiked = !_postLiked; _postLikes += _postLiked ? 1 : -1; }); }
  }

  void _showLikers() async {
    final likers = await _svc.getLikers(widget.post.id);
    if (!mounted) return;
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LikersSheet(likers: likers, onTap: _goProfile),
    );
  }

  void _goProfile(String id) {
    final me = context.read<AuthProvider>().currentUser?.id;
    if (me == id) Navigator.pushNamed(context, AppRoutes.profile);
    else Navigator.pushNamed(context, AppRoutes.userProfile, arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    final me = context.read<AuthProvider>().currentUser;
    final p  = widget.post;
    final a  = p.author;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Comments', style: TextStyle(
            fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A))),
      ),
      body: Column(children: [
        Expanded(
          child: CustomScrollView(slivers: [

            // ── Post at top ───────────────────────────────────────────────
            SliverToBoxAdapter(child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Author
                GestureDetector(
                  onTap: () => _goProfile(a.id),
                  child: Row(children: [
                    Stack(children: [
                      AvatarWidget(initials: a.initials, avatarUrl: a.avatarUrl, size: 44),
                      if (a.isOnline) Positioned(right: 1, bottom: 1,
                        child: Container(width: 11, height: 11,
                          decoration: BoxDecoration(color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2)),
                        )),
                    ]),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                      if (a.title.isNotEmpty)
                        Text(a.title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5)),
                      Text(p.timeAgo, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 10),
                // Content
                Text(p.content, style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),

                // Like bar
                Row(children: [
                  // Like button
                  GestureDetector(
                    onTap: _togglePostLike,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _postLiked ? AppTheme.primary.withOpacity(0.09) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _postLiked ? AppTheme.primary : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_postLiked ? Icons.thumb_up_rounded : Icons.thumb_up_alt_outlined,
                            size: 16,
                            color: _postLiked ? AppTheme.primary : const Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(_postLiked ? 'Liked' : 'Like',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                color: _postLiked ? AppTheme.primary : const Color(0xFF64748B))),
                      ]),
                    ),
                  ),
                  if (_postLikes > 0) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _showLikers,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 22, height: 22,
                          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.thumb_up_rounded, size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Text('$_postLikes ${_postLikes == 1 ? "like" : "likes"}',
                            style: const TextStyle(color: Color(0xFF64748B),
                                fontSize: 13, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ],
                ]),
              ]),
            )),

            // ── Separator ─────────────────────────────────────────────────
            SliverToBoxAdapter(child: Container(height: 8, color: const Color(0xFFF2F3F7))),

            // ── Comments header ───────────────────────────────────────────
            SliverToBoxAdapter(child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(children: [
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('${_comments.length}', style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ]),
            )),

            // ── Comments list ─────────────────────────────────────────────
            if (_loading)
              const SliverToBoxAdapter(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(
                    color: AppTheme.primary, strokeWidth: 2.5)),
              ))
            else if (_comments.isEmpty)
              SliverToBoxAdapter(child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 48,
                      color: const Color(0xFF94A3B8).withOpacity(0.3)),
                  const SizedBox(height: 12),
                  const Text('No comments yet', style: TextStyle(
                      fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 4),
                  const Text('Be the first to comment!',
                      style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
                ]),
              ))
            else
              SliverList(delegate: SliverChildBuilderDelegate(
                (_, i) => _CommentTile(
                  comment: _comments[i],
                  onProfileTap: _goProfile,
                  onReply: (c) {
                    setState(() => _replyingTo = c);
                    Future.delayed(const Duration(milliseconds: 100),
                        () => _focusNode.requestFocus());
                  },
                  onLike: (id) async {
                    final liked = await _svc.likeComment(id);
                    setState(() {
                      final idx = _comments.indexWhere((c) => c.id == id);
                      if (idx != -1) _comments[idx] = _comments[idx].withLike(liked);
                      // Also check replies
                      for (int j = 0; j < _comments.length; j++) {
                        final ri = _comments[j].replies.indexWhere((r) => r.id == id);
                        if (ri != -1) {
                          final updated = _comments[j].replies.toList();
                          updated[ri] = updated[ri].withLike(liked);
                          _comments[j] = _comments[j].copyWith(replies: updated);
                        }
                      }
                    });
                  },
                ),
                childCount: _comments.length,
              )),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ]),
        ),

        // ── Reply banner ──────────────────────────────────────────────────
        if (_replyingTo != null)
          Container(
            color: AppTheme.primary.withOpacity(0.07),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Icon(Icons.reply_rounded, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text('Replying to ${_replyingTo!.authorName}',
                  style: const TextStyle(color: AppTheme.primary,
                      fontWeight: FontWeight.w600, fontSize: 13))),
              GestureDetector(
                onTap: () { setState(() => _replyingTo = null); _inputCtrl.clear(); _focusNode.unfocus(); },
                child: const Icon(Icons.close_rounded, size: 18, color: AppTheme.primary),
              ),
            ]),
          ),

        // ── Input ─────────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(12, 10, 12,
              MediaQuery.of(context).viewInsets.bottom + 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            AvatarWidget(initials: me?.initials ?? '?', avatarUrl: me?.avatarUrl, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE2E8F0))),
                child: TextField(
                  controller: _inputCtrl, focusNode: _focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _replyingTo != null
                        ? 'Reply to ${_replyingTo!.authorName}...'
                        : 'Add a comment...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sending ? null : _send,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: _sending ? AppTheme.primary.withOpacity(0.5) : AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.35),
                        blurRadius: 8, offset: const Offset(0, 3))]),
                child: _sending
                    ? const Padding(padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 17, color: Colors.white),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Comment tile ─────────────────────────────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final _CommentItem comment;
  final ValueChanged<String> onProfileTap;
  final ValueChanged<_CommentItem> onReply;
  final ValueChanged<String> onLike;
  const _CommentTile({required this.comment, required this.onProfileTap,
      required this.onReply, required this.onLike});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Bubble(comment: comment, onProfileTap: onProfileTap,
          onReply: () => onReply(comment), onLike: () => onLike(comment.id)),
      // Replies
      if (comment.replies.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(left: 40, top: 6),
          child: Column(children: comment.replies.map((r) =>
            _Bubble(comment: r, onProfileTap: onProfileTap,
                isReply: true, onLike: () => onLike(r.id))
          ).toList()),
        ),
      const Divider(height: 16, color: Color(0xFFF1F5F9)),
    ]),
  );
}

class _Bubble extends StatelessWidget {
  final _CommentItem comment;
  final ValueChanged<String> onProfileTap;
  final VoidCallback? onReply;
  final VoidCallback onLike;
  final bool isReply;
  const _Bubble({required this.comment, required this.onProfileTap,
      this.onReply, required this.onLike, this.isReply = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => onProfileTap(comment.authorId),
        child: AvatarWidget(initials: comment.authorInitials,
            avatarUrl: comment.authorAvatar, size: isReply ? 28 : 36),
      ),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Bubble
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
          decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4), topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16),
              )),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () => onProfileTap(comment.authorId),
              child: Text(comment.authorName,
                  style: const TextStyle(fontWeight: FontWeight.w700,
                      fontSize: 12.5, color: Color(0xFF0F172A))),
            ),
            const SizedBox(height: 3),
            Text(comment.content, style: const TextStyle(
                fontSize: 13.5, height: 1.45, color: Color(0xFF334155))),
          ]),
        ),
        // Actions
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 4),
          child: Row(children: [
            Text(comment.timeAgo, style: const TextStyle(
                fontSize: 11, color: Color(0xFF94A3B8))),
            const SizedBox(width: 14),
            GestureDetector(
              onTap: onLike,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(comment.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 14,
                    color: comment.isLiked ? Colors.red : const Color(0xFF94A3B8)),
                if (comment.likesCount > 0) ...[
                  const SizedBox(width: 3),
                  Text('${comment.likesCount}', style: TextStyle(
                      fontSize: 11,
                      color: comment.isLiked ? Colors.red : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600)),
                ],
              ]),
            ),
            if (!isReply && onReply != null) ...[
              const SizedBox(width: 14),
              GestureDetector(
                onTap: onReply,
                child: const Text('Reply', style: TextStyle(
                    fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ),
            ],
          ]),
        ),
      ])),
    ]),
  );
}

// ─── Likers sheet ─────────────────────────────────────────────────────────────
class _LikersSheet extends StatelessWidget {
  final List<Map<String, dynamic>> likers;
  final ValueChanged<String> onTap;
  const _LikersSheet({required this.likers, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 12),
      Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 28, height: 28,
          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
          child: const Icon(Icons.thumb_up_rounded, size: 15, color: Colors.white)),
        const SizedBox(width: 8),
        Text('${likers.length} ${likers.length == 1 ? "like" : "likes"}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ]),
      const SizedBox(height: 8),
      const Divider(height: 1),
      Flexible(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        itemCount: likers.length,
        itemBuilder: (_, i) {
          final u = likers[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            leading: AvatarWidget(initials: u['initials'] as String? ?? '?',
                avatarUrl: u['avatar_url'] as String?, size: 44),
            title: Text(u['full_name'] as String? ?? '',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: (u['title'] as String? ?? '').isNotEmpty
                ? Text(u['title'] as String,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12))
                : null,
            onTap: () { Navigator.pop(context); onTap(u['id'] as String? ?? ''); },
          );
        },
      )),
    ]),
  );
}

// ─── Data model ───────────────────────────────────────────────────────────────
class _CommentItem {
  final String id, content, authorId, authorName, authorInitials;
  final String? authorAvatar;
  final DateTime createdAt;
  final bool isLiked;
  final int likesCount;
  final List<_CommentItem> replies;

  const _CommentItem({
    required this.id, required this.content,
    required this.authorId, required this.authorName,
    required this.authorInitials, this.authorAvatar,
    required this.createdAt, this.isLiked = false,
    this.likesCount = 0, this.replies = const [],
  });

  factory _CommentItem.fromMap(Map<String, dynamic> m) {
    final a = (m['author'] as Map<String, dynamic>?) ?? {};
    return _CommentItem(
      id: m['id'] as String? ?? '', content: m['content'] as String? ?? '',
      authorId: a['id'] as String? ?? '', authorName: a['full_name'] as String? ?? '',
      authorInitials: a['initials'] as String? ?? '?', authorAvatar: a['avatar_url'] as String?,
      createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
      isLiked: m['is_liked'] == true, likesCount: (m['likes_count'] as int?) ?? 0,
      replies: ((m['replies'] as List?) ?? [])
          .map((r) => _CommentItem.fromMap(r as Map<String, dynamic>)).toList(),
    );
  }

  String get timeAgo {
    final d = DateTime.now().difference(createdAt);
    if (d.inSeconds < 60) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours   < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  _CommentItem withLike(bool liked) => copyWith(
    isLiked: liked,
    likesCount: liked ? likesCount + 1 : (likesCount - 1).clamp(0, 999999),
  );

  _CommentItem withReply(_CommentItem r) => copyWith(replies: [...replies, r]);

  _CommentItem copyWith({
    bool? isLiked, int? likesCount, List<_CommentItem>? replies,
  }) => _CommentItem(
    id: id, content: content, authorId: authorId, authorName: authorName,
    authorInitials: authorInitials, authorAvatar: authorAvatar, createdAt: createdAt,
    isLiked: isLiked ?? this.isLiked,
    likesCount: likesCount ?? this.likesCount,
    replies: replies ?? this.replies,
  );
}