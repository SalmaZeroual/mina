import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/group_model.dart';
import '../../providers/groups_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/group_service.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../widgets/common/loading_widget.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});
  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  final _service = GroupService();
  late TabController _tabs;

  GroupModel? _group;
  List<GroupPostModel> _posts = [];
  List<GroupMemberModel> _members = [];
  List<JoinRequestModel> _requests = [];

  bool _loadingGroup = true;
  bool _loadingPosts = false;
  bool _showRequests = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loadingGroup = true);
    try {
      final group = await _service.getGroup(widget.groupId);
      List<JoinRequestModel> requests = [];
      List<GroupMemberModel> members = [];
      if (group.isAdmin) {
        requests = await _service.getJoinRequests(widget.groupId);
        members  = await _service.getMembers(widget.groupId);
      }
      if (group.isMember && !group.isAdmin) {
        members = await _service.getMembers(widget.groupId);
      }
      setState(() {
        _group = group; _requests = requests; _members = members;
        _loadingGroup = false;
      });
      if (group.isMember) _loadPosts();
    } catch (_) {
      setState(() => _loadingGroup = false);
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _loadingPosts = true);
    try {
      final posts = await _service.getPosts(widget.groupId);
      setState(() { _posts = posts; _loadingPosts = false; });
    } catch (_) {
      setState(() => _loadingPosts = false);
    }
  }

  Future<void> _join() async {
    final result = await context.read<GroupsProvider>().joinGroup(widget.groupId);
    if (!mounted) return;
    if (result != null) {
      final status = result['data']?['status'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(status == 'pending'
            ? '📬 Request sent! Waiting for approval.'
            : '🎉 You joined the community!'),
        backgroundColor: status == 'pending' ? Colors.orange : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      _load();
    }
  }

  Future<void> _leave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Leave Community?'),
        content: Text('Are you sure you want to leave "${_group?.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await context.read<GroupsProvider>().leaveGroup(widget.groupId);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _handleRequest(JoinRequestModel req, String action) async {
    await _service.handleRequest(widget.groupId, req.id, action);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(action == 'approve'
          ? '✅ ${req.user['full_name']} approved!'
          : '❌ Request declined'),
      backgroundColor: action == 'approve' ? AppTheme.success : Colors.grey[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingGroup) return const Scaffold(body: LoadingWidget());
    if (_group == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Community not found')));
    }

    final g = _group!;
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final isCreator = g.creatorId == currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _cellColor(g.cell),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (g.isAdmin && _requests.isNotEmpty)
                IconButton(
                  icon: Stack(children: [
                    const Icon(Icons.notifications_outlined, color: Colors.white),
                    Positioned(right: 0, top: 0, child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      child: Center(child: Text('${_requests.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                    )),
                  ]),
                  onPressed: () => setState(() => _showRequests = !_showRequests),
                ),
              if (isCreator)
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => _showGroupSettings(context),
                ),
              if (g.isMember && !isCreator)
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'leave', child: Row(children: [
                      Icon(Icons.exit_to_app, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Leave', style: TextStyle(color: Colors.red)),
                    ])),
                  ],
                  onSelected: (v) { if (v == 'leave') _leave(); },
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_cellColor(g.cell).withOpacity(0.85), _cellColor(g.cell)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end, children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16)),
                      child: Center(child: Text(_groupEmoji(g.name),
                          style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(height: 12),
                    Text(g.name, style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Row(children: [
                      if (g.cell != null)
                        Text(g.cell!, style: TextStyle(
                            color: Colors.white.withOpacity(0.8), fontSize: 13)),
                      const Spacer(),
                      if (!g.isFree)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('\$${g.price.toInt()}/mo',
                              style: const TextStyle(color: Colors.black87,
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ]),
                  ]),
                )),
              ),
            ),
          ),
          SliverToBoxAdapter(child: Column(children: [
            // Stats bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                if (g.showMembersCount)
                  _Stat(value: _fmt(g.membersCount), label: 'Members',
                      icon: Icons.people_outline)
                else
                  _Stat(value: '—', label: 'Members', icon: Icons.people_outline),
                _vdivider(),
                _Stat(
                    value: g.requiresApproval ? 'Approval' : 'Open',
                    label: 'Access',
                    icon: g.requiresApproval ? Icons.lock_outline : Icons.lock_open_outlined),
                _vdivider(),
                _Stat(
                    value: g.isFree ? 'Free' : '\$${g.price.toInt()}',
                    label: 'Membership',
                    icon: g.isFree ? Icons.card_membership_outlined : Icons.monetization_on_outlined),
              ]),
            ),

            // Join requests panel
            if (g.isAdmin && _showRequests && _requests.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(children: [
                      const Icon(Icons.pending_actions, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Text('${_requests.length} Pending Request${_requests.length > 1 ? 's' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ]),
                  ),
                  const Divider(height: 1),
                  ..._requests.map((r) => _RequestTile(request: r, onAction: _handleRequest)),
                ]),
              ),
            ],

            // Tabs
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabs,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(icon: Icon(Icons.article_outlined, size: 18), text: 'Discussions'),
                  Tab(icon: Icon(Icons.people_outlined, size: 18), text: 'Members'),
                ],
              ),
            ),
          ])),
        ],
        body: g.isMember
            ? TabBarView(
                controller: _tabs,
                children: [
                  // ── Discussions tab ─────────────────────────────────────────
                  _DiscussionsTab(
                    posts: _posts,
                    loading: _loadingPosts,
                    group: g,
                    onRefresh: _loadPosts,
                    onPostCreated: (post) => setState(() => _posts.insert(0, post)),
                    onPostDeleted: (id) => setState(() => _posts.removeWhere((p) => p.id == id)),
                    onLike: (postId, liked, count) {
                      setState(() {
                        final idx = _posts.indexWhere((p) => p.id == postId);
                        if (idx >= 0) _posts[idx] = _posts[idx].copyWith(isLiked: liked, likesCount: count);
                      });
                    },
                    onPin: (postId, pinned) {
                      setState(() {
                        final idx = _posts.indexWhere((p) => p.id == postId);
                        if (idx >= 0) _posts[idx] = _posts[idx].copyWith(isPinned: pinned);
                        _posts.sort((a, b) => b.isPinned && !a.isPinned ? 1 : -1);
                      });
                    },
                  ),
                  // ── Members tab ─────────────────────────────────────────────
                  _MembersTab(
                    members: _members,
                    group: g,
                    currentUserId: context.read<AuthProvider>().currentUser?.id ?? '',
                    onAction: _load,
                  ),
                ],
              )
            : _JoinPrompt(group: g, onJoin: _join),
      ),

      // Join button for non-members
      bottomNavigationBar: g.isMember
          ? null
          : SafeArea(child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: g.isPending ? null : _join,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: g.isPending ? Colors.grey[400] : AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    g.isPending ? '⏳ Request Pending...'
                        : (g.requiresApproval ? '📬 Request to Join'
                            : (g.isFree ? '🚀 Join Community' : '💳 Subscribe \$${g.price.toInt()}/mo')),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )),
    );
  }

  void _showGroupSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GroupSettingsSheet(
        group: _group!,
        members: _members,
        onUpdated: _load,
      ),
    );
  }

  Widget _vdivider() => Container(height: 30, width: 1, color: AppTheme.border);

  Color _cellColor(String? cell) {
    const colors = {
      'Web Development': Color(0xFF6366F1), 'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6),        'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6),       'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981),         'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444),       'Photography': Color(0xFFF97316),
    };
    return colors[cell] ?? AppTheme.primary;
  }

  String _groupEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('flutter') || n.contains('dev') || n.contains('code')) return '💻';
    if (n.contains('design') || n.contains('ui')) return '🎨';
    if (n.contains('startup') || n.contains('business')) return '🚀';
    if (n.contains('freelance')) return '💼';
    if (n.contains('data') || n.contains('ai')) return '🤖';
    if (n.contains('health') || n.contains('medic')) return '🏥';
    if (n.contains('finance')) return '📈';
    return '🌐';
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

// ── Discussions tab ───────────────────────────────────────────────────────────
class _DiscussionsTab extends StatelessWidget {
  final List<GroupPostModel> posts;
  final bool loading;
  final GroupModel group;
  final VoidCallback onRefresh;
  final Function(GroupPostModel) onPostCreated;
  final Function(String) onPostDeleted;
  final Function(String, bool, int) onLike;
  final Function(String, bool) onPin;

  const _DiscussionsTab({
    required this.posts, required this.loading, required this.group,
    required this.onRefresh, required this.onPostCreated,
    required this.onPostDeleted, required this.onLike, required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
        children: [
          // Composer (admin only)
          if (group.isAdmin) _PostComposer(group: group, onCreated: onPostCreated),

          if (loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppTheme.primary),
            ))
          else if (posts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Column(children: [
                Icon(Icons.forum_outlined, size: 52,
                    color: AppTheme.textSecondary.withOpacity(0.4)),
                const SizedBox(height: 16),
                const Text('No discussions yet',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                if (group.isAdmin)
                  const Text('Be the first to share something!',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ]),
            )
          else
            ...posts.map((p) => _PostCard(
              post: p, group: group,
              onDeleted: () => onPostDeleted(p.id),
              onLike: onLike,
              onPin: onPin,
            )),
        ],
      ),
    );
  }
}

// ── Post composer ─────────────────────────────────────────────────────────────
class _PostComposer extends StatefulWidget {
  final GroupModel group;
  final Function(GroupPostModel) onCreated;
  const _PostComposer({required this.group, required this.onCreated});
  @override
  State<_PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<_PostComposer> {
  final _ctrl = TextEditingController();
  final _service = GroupService();
  bool _publishing = false;

  Future<void> _publish() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _publishing = true);
    try {
      final post = await _service.createPost(widget.group.id, text);
      _ctrl.clear();
      widget.onCreated(post);
      HapticFeedback.lightImpact();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()), backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.edit_outlined, size: 12, color: AppTheme.primary),
              const SizedBox(width: 4),
              const Text('Post as Admin', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _ctrl,
          maxLines: null,
          minLines: 2,
          decoration: const InputDecoration(
            hintText: 'Share knowledge, resources, or start a discussion...',
            hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: _publishing ? null : _publish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                elevation: 0,
              ),
              child: _publishing
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Publish', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Post card ─────────────────────────────────────────────────────────────────
class _PostCard extends StatefulWidget {
  final GroupPostModel post;
  final GroupModel group;
  final VoidCallback onDeleted;
  final Function(String, bool, int) onLike;
  final Function(String, bool) onPin;
  const _PostCard({
    required this.post, required this.group,
    required this.onDeleted, required this.onLike, required this.onPin,
  });
  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  final _service = GroupService();
  bool _expanded = false;
  bool _liking = false;

  Future<void> _like() async {
    if (_liking) return;
    setState(() => _liking = true);
    try {
      final liked = await _service.likeGroupPost(widget.post.id);
      final newCount = liked
          ? widget.post.likesCount + 1
          : (widget.post.likesCount - 1).clamp(0, 999999);
      widget.onLike(widget.post.id, liked, newCount);
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final author = post.author;
    final isAdmin = widget.group.isAdmin;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: post.isPinned
            ? Border.all(color: AppTheme.primary.withOpacity(0.4), width: 1.5)
            : Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Pinned badge
        if (post.isPinned)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(children: [
              Icon(Icons.push_pin, size: 13, color: AppTheme.primary),
              SizedBox(width: 5),
              Text('Pinned', style: TextStyle(
                  fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ]),
          ),

        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Author row
            Row(children: [
              AvatarWidget(
                initials: author['initials'] as String? ?? '?',
                avatarUrl: author['avatar_url'] as String?,
                size: 38,
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(author['full_name'] as String? ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      author['role'] == 'admin' ? 'Admin' : 'Member',
                      style: const TextStyle(fontSize: 9,
                          fontWeight: FontWeight.w700, color: AppTheme.primary),
                    ),
                  ),
                ]),
                Text(post.timeAgo,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ])),
              if (isAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: AppTheme.textSecondary, size: 18),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'pin',
                        child: Row(children: [
                          Icon(post.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                              size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(post.isPinned ? 'Unpin' : 'Pin'),
                        ])),
                    const PopupMenuItem(value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ])),
                  ],
                  onSelected: (v) async {
                    if (v == 'pin') {
                      final pinned = await _service.togglePinPost(widget.group.id, post.id);
                      widget.onPin(post.id, pinned);
                    } else if (v == 'delete') {
                      await _service.deletePost(widget.group.id, post.id);
                      widget.onDeleted();
                    }
                  },
                ),
            ]),
            const SizedBox(height: 12),

            // Content
            Text(
              post.content,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF1A1A2E)),
              maxLines: _expanded ? null : 6,
              overflow: _expanded ? null : TextOverflow.fade,
            ),
            if (post.content.length > 300) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'Show less' : 'Read more',
                    style: const TextStyle(color: AppTheme.primary,
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Actions
            Row(children: [
              _ActionBtn(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                color: post.isLiked ? Colors.red : AppTheme.textSecondary,
                label: post.likesCount > 0 ? '${post.likesCount}' : '',
                onTap: _like,
              ),
              const SizedBox(width: 16),
              _ActionBtn(
                icon: Icons.chat_bubble_outline,
                color: AppTheme.textSecondary,
                label: post.commentsCount > 0 ? '${post.commentsCount}' : '',
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _CommentsSheet(
                    groupId: widget.group.id,
                    post: post,
                    isMember: widget.group.isMember,
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color,
      required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(children: [
      Icon(icon, size: 18, color: color),
      if (label.isNotEmpty) ...[
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
      ],
    ]),
  );
}

// ── Comments sheet ────────────────────────────────────────────────────────────
class _CommentsSheet extends StatefulWidget {
  final String groupId;
  final GroupPostModel post;
  final bool isMember;
  const _CommentsSheet({required this.groupId, required this.post, required this.isMember});
  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _service = GroupService();
  final _ctrl = TextEditingController();
  List<GroupCommentModel> _comments = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final c = await _service.getComments(widget.groupId, widget.post.id);
      setState(() { _comments = c; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final c = await _service.addComment(widget.groupId, widget.post.id, text);
      _ctrl.clear();
      setState(() => _comments.add(c));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Center(child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            if (_comments.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text('${_comments.length}',
                    style: const TextStyle(color: AppTheme.primary,
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _comments.isEmpty
                  ? const Center(child: Text('No comments yet. Be the first!',
                      style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _comments.length,
                      itemBuilder: (_, i) => _CommentTile(comment: _comments[i]),
                    ),
        ),
        if (widget.isMember)
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sending ? null : _send,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _sending
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final GroupCommentModel comment;
  const _CommentTile({required this.comment});
  @override
  Widget build(BuildContext context) {
    final a = comment.author;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AvatarWidget(
          initials: a['initials'] as String? ?? '?',
          avatarUrl: a['avatar_url'] as String?,
          size: 34,
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a['full_name'] as String? ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 3),
              Text(comment.content, style: const TextStyle(fontSize: 13, height: 1.4)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 3),
            child: Text(_timeAgo(comment.createdAt),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
          ),
        ])),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24)   return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

// ── Members tab ───────────────────────────────────────────────────────────────
class _MembersTab extends StatelessWidget {
  final List<GroupMemberModel> members;
  final GroupModel group;
  final String currentUserId;
  final VoidCallback onAction;
  const _MembersTab({
    required this.members, required this.group,
    required this.currentUserId, required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Center(child: Text('No members yet',
          style: TextStyle(color: AppTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: members.length,
      itemBuilder: (_, i) => _MemberTile(
        member: members[i],
        group: group,
        currentUserId: currentUserId,
        onAction: onAction,
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final GroupMemberModel member;
  final GroupModel group;
  final String currentUserId;
  final VoidCallback onAction;
  const _MemberTile({
    required this.member, required this.group,
    required this.currentUserId, required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isCreator = group.creatorId == currentUserId;
    final isSelf    = member.id == currentUserId;
    final service   = GroupService();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Stack(children: [
          AvatarWidget(initials: member.initials, avatarUrl: member.avatarUrl, size: 42),
          if (member.isOnline)
            Positioned(right: 0, bottom: 0, child: Container(
              width: 11, height: 11,
              decoration: BoxDecoration(
                color: AppTheme.success, shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5)),
            )),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(member.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            if (member.role == 'admin') ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  group.creatorId == member.id ? '👑 Creator' : 'Admin',
                  style: const TextStyle(color: AppTheme.primary,
                      fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ]),
          if (member.title.isNotEmpty)
            Text(member.title,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ])),

        // Admin actions (creator only, not on self)
        if (isCreator && !isSelf && group.creatorId != member.id)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textSecondary),
            itemBuilder: (_) => [
              if (member.role != 'admin')
                const PopupMenuItem(value: 'promote', child: Row(children: [
                  Icon(Icons.star_outline, size: 16, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Text('Make Admin'),
                ]))
              else
                const PopupMenuItem(value: 'demote', child: Row(children: [
                  Icon(Icons.person_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Remove Admin'),
                ])),
              const PopupMenuItem(value: 'remove', child: Row(children: [
                Icon(Icons.person_remove_outlined, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('Remove from group', style: TextStyle(color: Colors.red)),
              ])),
            ],
            onSelected: (v) async {
              if (v == 'promote') {
                await service.promoteToAdmin(group.id, member.id);
                onAction();
              } else if (v == 'demote') {
                await service.demoteAdmin(group.id, member.id);
                onAction();
              } else if (v == 'remove') {
                await service.removeMember(group.id, member.id);
                onAction();
              }
            },
          ),
      ]),
    );
  }
}

// ── Join prompt ───────────────────────────────────────────────────────────────
class _JoinPrompt extends StatelessWidget {
  final GroupModel group;
  final VoidCallback onJoin;
  const _JoinPrompt({required this.group, required this.onJoin});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.lock_outline, size: 52, color: AppTheme.textSecondary.withOpacity(0.4)),
        const SizedBox(height: 16),
        const Text('Members Only', style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Text(
          group.requiresApproval
              ? 'Join this community to access discussions and resources.'
              : 'Join to access all discussions and connect with members.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
        ),
      ]),
    ),
  );
}

// ── Group settings sheet ──────────────────────────────────────────────────────
class _GroupSettingsSheet extends StatefulWidget {
  final GroupModel group;
  final List<GroupMemberModel> members;
  final VoidCallback onUpdated;
  const _GroupSettingsSheet({
    required this.group, required this.members, required this.onUpdated,
  });
  @override
  State<_GroupSettingsSheet> createState() => _GroupSettingsSheetState();
}

class _GroupSettingsSheetState extends State<_GroupSettingsSheet> {
  final _service = GroupService();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late bool _requiresApproval;
  late bool _showMembers;
  late bool _isFree;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl       = TextEditingController(text: widget.group.name);
    _descCtrl       = TextEditingController(text: widget.group.description);
    _priceCtrl      = TextEditingController(text: widget.group.price.toInt().toString());
    _requiresApproval = widget.group.requiresApproval;
    _showMembers    = widget.group.showMembersCount;
    _isFree         = widget.group.isFree;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.updateGroup(widget.group.id, {
        'name':               _nameCtrl.text.trim(),
        'description':        _descCtrl.text.trim(),
        'requires_approval':  _requiresApproval,
        'show_members_count': _showMembers,
        'is_free':            _isFree,
        if (!_isFree) 'price': double.tryParse(_priceCtrl.text) ?? 0,
      });
      if (mounted) {
        Navigator.pop(context);
        widget.onUpdated();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Settings saved!'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()), backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),
          const Text('Community Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Name
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Description', alignLabelWithHint: true),
          ),
          const SizedBox(height: 16),

          // Toggles
          _ToggleTile(
            icon: Icons.lock_outline,
            title: 'Require Approval',
            subtitle: 'Review each join request',
            value: _requiresApproval,
            onChanged: (v) => setState(() => _requiresApproval = v),
          ),
          const SizedBox(height: 8),
          _ToggleTile(
            icon: Icons.people_outline,
            title: 'Show Members Count',
            subtitle: 'Display number of members publicly',
            value: _showMembers,
            onChanged: (v) => setState(() => _showMembers = v),
          ),
          const SizedBox(height: 8),
          _ToggleTile(
            icon: Icons.card_membership_outlined,
            title: 'Free Community',
            subtitle: _isFree ? 'Anyone can join for free' : 'Paid subscription required',
            value: _isFree,
            onChanged: (v) => setState(() => _isFree = v),
          ),
          if (!_isFree) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly price (\$)',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.icon, required this.title, required this.subtitle,
    required this.value, required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border),
    ),
    child: SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primary, size: 20),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primary,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    ),
  );
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  final String value, label; final IconData icon;
  const _Stat({required this.value, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 18, color: AppTheme.primary),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
  ]);
}

class _RequestTile extends StatelessWidget {
  final JoinRequestModel request;
  final Function(JoinRequestModel, String) onAction;
  const _RequestTile({required this.request, required this.onAction});
  @override
  Widget build(BuildContext context) {
    final user = request.user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        AvatarWidget(
            initials: user['initials'] as String? ?? '?',
            avatarUrl: user['avatar_url'] as String?,
            size: 40),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user['full_name'] as String? ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(user['title'] as String? ?? '',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ])),
        Row(children: [
          GestureDetector(
            onTap: () => onAction(request, 'reject'),
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.red, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onAction(request, 'approve'),
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: AppTheme.success, size: 18),
            ),
          ),
        ]),
      ]),
    );
  }
}