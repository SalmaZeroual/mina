import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../models/message_model.dart';
import '../../services/user_service.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../widgets/home/post_card.dart';
import '../../config/routes.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _svc = UserService();

  UserModel? _user;
  List<PostModel> _posts = [];
  List<UserModel> _followers = [];
  List<UserModel> _following = [];
  bool _loading = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _svc.getProfile(widget.userId),
        _svc.getUserPosts(widget.userId),
        _svc.getFollowers(widget.userId),
        _svc.getFollowing(widget.userId),
      ]);
      _user      = results[0] as UserModel;
      final raw  = results[1] as List;
      _posts     = raw.map((j) => PostModel.fromJson(j as Map<String, dynamic>)).toList();
      _followers = results[2] as List<UserModel>;
      _following = results[3] as List<UserModel>;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  // ── Follow / Unfollow ───────────────────────────────────────────────────────
  Future<void> _toggleFollow() async {
    if (_user == null || _actionLoading) return;
    setState(() => _actionLoading = true);
    try {
      if (_user!.isFollowing) {
        await _svc.unfollow(_user!.id);
      } else {
        await _svc.follow(_user!.id);
      }
      await _load();
    } catch (e) { _snack(e.toString(), isError: true); }
    if (mounted) setState(() => _actionLoading = false);
  }

  // ── Connect / Cancel ────────────────────────────────────────────────────────
  Future<void> _toggleConnect() async {
    if (_user == null || _actionLoading) return;
    setState(() => _actionLoading = true);
    try {
      if (_user!.isConnected) {
        await _svc.removeConnection(_user!.id);
        _snack('Connection removed');
      } else if (_user!.isPendingConnection && _user!.iAmRequester) {
        await _svc.removeConnection(_user!.id);
        _snack('Request cancelled');
      } else if (_user!.isPendingConnection && !_user!.iAmRequester) {
        await _svc.acceptConnection(_user!.connectionId!);
        _snack('✅ Connected!');
      } else {
        await _svc.sendConnectionRequest(_user!.id);
        _snack('Connection request sent!');
      }
      await _load();
    } catch (e) { _snack(e.toString().replaceAll('Exception: ', ''), isError: true); }
    if (mounted) setState(() => _actionLoading = false);
  }

  // ── Message (only if connected) ─────────────────────────────────────────────
  Future<void> _openMessage() async {
    if (_user == null) return;
    if (!_user!.isConnected) {
      _snack('Connect with this person to send messages');
      return;
    }
    setState(() => _actionLoading = true);
    try {
      final data = await ApiService.post('/messages/conversations/${_user!.id}', {});
      final conv = ConversationModel.fromJson(data['data'] as Map<String, dynamic>);
      if (mounted) Navigator.pushNamed(context, AppRoutes.chat, arguments: conv);
    } catch (e) { _snack(e.toString(), isError: true); }
    if (mounted) setState(() => _actionLoading = false);
  }

  void _showMenu() {
    if (_user == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MenuSheet(
        user: _user!,
        onBlock: () async {
          await _svc.blockUser(_user!.id);
          if (mounted) Navigator.pop(context);
          _snack('User blocked');
          await _load();
        },
        onReport: () {
          Navigator.pop(context);
          _snack('Report submitted. Thank you.');
        },
        onRemoveConnection: _user!.isConnected ? () async {
          await _svc.removeConnection(_user!.id);
          Navigator.pop(context);
          _snack('Connection removed');
          await _load();
        } : null,
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: LoadingWidget(),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('User not found')),
      );
    }

    final u = _user!;
    final myId = context.read<AuthProvider>().currentUser?.id;
    final isMe = myId == u.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildAppBar(u, isMe)],
        body: Column(children: [
          // Identity card
          _IdentityCard(
            user: u,
            isMe: isMe,
            actionLoading: _actionLoading,
            onFollow: _toggleFollow,
            onConnect: _toggleConnect,
            onMessage: _openMessage,
          ),
          const SizedBox(height: 8),
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: 'Posts (${_posts.length})'),
                Tab(text: 'Followers (${_followers.length})'),
                Tab(text: 'Following (${_following.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // Posts
                _posts.isEmpty
                    ? _Empty(icon: Icons.article_outlined,
                        title: 'No posts yet',
                        sub: '${u.fullName.split(' ').first} hasn\'t posted anything yet')
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
                        itemCount: _posts.length,
                        itemBuilder: (_, i) => PostCard(post: _posts[i]),
                      ),
                // Followers
                _followers.isEmpty
                    ? _Empty(icon: Icons.people_outline, title: 'No followers yet', sub: '')
                    : _UserList(users: _followers),
                // Following
                _following.isEmpty
                    ? _Empty(icon: Icons.person_add_alt_outlined, title: 'Not following anyone', sub: '')
                    : _UserList(users: _following),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  SliverAppBar _buildAppBar(UserModel u, bool isMe) => SliverAppBar(
    expandedHeight: 160,
    pinned: true,
    backgroundColor: Colors.white,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
    actions: [
      if (!isMe)
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: _showMenu,
        ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      background: Stack(fit: StackFit.expand, children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_cellColor(u.cell), _cellColor(u.cell).withOpacity(0.6),
                  const Color(0xFF1A1A2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0x99000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          bottom: 14, left: 80,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(u.fullName,
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 18)),
            if (u.title.isNotEmpty)
              Text(u.title, style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ]),
        ),
        Positioned(
          bottom: 6, left: 16,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Stack(children: [
              AvatarWidget(initials: u.initials, avatarUrl: u.avatarUrl, size: 56),
              if (u.isOnline)
                Positioned(
                  right: 2, bottom: 2,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                  ),
                ),
            ]),
          ),
        ),
      ]),
    ),
  );

  Color _cellColor(String? cell) {
    const m = {
      'Web Development': Color(0xFF6366F1), 'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6),        'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6),       'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981),         'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444),
    };
    return m[cell] ?? AppTheme.primary;
  }
}

// ── Identity card ─────────────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final UserModel user;
  final bool isMe, actionLoading;
  final VoidCallback onFollow, onConnect, onMessage;
  const _IdentityCard({
    required this.user, required this.isMe,
    required this.actionLoading,
    required this.onFollow, required this.onConnect, required this.onMessage,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Badges
      Wrap(spacing: 8, runSpacing: 6, children: [
        if (user.cell.isNotEmpty)
          _Badge(icon: Icons.grid_view_rounded, label: user.cell,
              color: _cellColor(user.cell)),
        if (user.company != null && user.company!.isNotEmpty)
          _Badge(icon: Icons.business_outlined, label: user.company!,
              color: const Color(0xFF374151)),
        if (user.location != null && user.location!.isNotEmpty)
          _Badge(icon: Icons.location_on_outlined, label: user.location!,
              color: const Color(0xFF374151)),
      ]),
      const SizedBox(height: 14),

      // Stats
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _Stat(value: '${user.postsCount}',    label: 'Posts'),
          Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
          _Stat(value: '${user.followersCount}', label: 'Followers'),
          Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
          _Stat(value: '${user.followingCount}', label: 'Following'),
        ]),
      ),

      if (!isMe) ...[
        const SizedBox(height: 14),
        Row(children: [
          // Connect button
          Expanded(flex: 2, child: _ConnectButton(user: user, onTap: onConnect, loading: actionLoading)),
          const SizedBox(width: 8),
          // Follow button
          Expanded(child: _FollowButton(isFollowing: user.isFollowing, onTap: onFollow, loading: actionLoading)),
          const SizedBox(width: 8),
          // Message (only if connected)
          _MessageBtn(
            enabled: user.isConnected,
            onTap: onMessage,
            loading: actionLoading,
          ),
        ]),
      ],

      // About preview
      if (user.about != null && user.about!.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(user.about!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
      ],
    ]),
  );

  Color _cellColor(String? cell) {
    const m = {
      'Web Development': Color(0xFF6366F1), 'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6),        'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6),       'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981),         'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444),
    };
    return m[cell] ?? AppTheme.primary;
  }
}

class _Badge extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _Badge({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color), const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
  ]);
}

class _ConnectButton extends StatelessWidget {
  final UserModel user; final VoidCallback onTap; final bool loading;
  const _ConnectButton({required this.user, required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    String label; Color bg; Color fg; IconData icon;
    if (user.isConnected) {
      label = 'Connected'; bg = AppTheme.success.withOpacity(0.1);
      fg = AppTheme.success; icon = Icons.check_circle_outline;
    } else if (user.isPendingConnection && user.iAmRequester) {
      label = 'Pending...'; bg = const Color(0xFFF59E0B).withOpacity(0.1);
      fg = const Color(0xFFF59E0B); icon = Icons.hourglass_empty_rounded;
    } else if (user.isPendingConnection && !user.iAmRequester) {
      label = 'Accept'; bg = AppTheme.primary.withOpacity(0.1);
      fg = AppTheme.primary; icon = Icons.person_add_rounded;
    } else {
      label = 'Connect'; bg = AppTheme.primary;
      fg = Colors.white; icon = Icons.person_add_outlined;
    }

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(22)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          loading
              ? SizedBox(width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg))
              : Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: fg)),
        ]),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing, loading; final VoidCallback onTap;
  const _FollowButton({required this.isFollowing, required this.loading, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: isFollowing ? Colors.transparent : AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: isFollowing ? const Color(0xFFCBD5E1) : AppTheme.primary,
            width: 1.5),
      ),
      child: Center(child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: isFollowing ? AppTheme.textSecondary : AppTheme.primary))),
    ),
  );
}

class _MessageBtn extends StatelessWidget {
  final bool enabled, loading; final VoidCallback onTap;
  const _MessageBtn({required this.enabled, required this.loading, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: enabled
            ? AppTheme.primary.withOpacity(0.08)
            : Colors.grey.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(
            color: enabled ? AppTheme.primary : Colors.grey.withOpacity(0.3)),
      ),
      child: Icon(Icons.chat_bubble_outline,
          size: 17,
          color: enabled ? AppTheme.primary : Colors.grey.withOpacity(0.5)),
    ),
  );
}

// ── User list (followers / following) ─────────────────────────────────────────
class _UserList extends StatelessWidget {
  final List<UserModel> users;
  const _UserList({required this.users});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
    itemCount: users.length,
    itemBuilder: (_, i) {
      final u = users[i];
      return GestureDetector(
        onTap: () => Navigator.pushNamed(
            context, AppRoutes.userProfile, arguments: u.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9ECF2))),
          child: Row(children: [
            AvatarWidget(initials: u.initials, avatarUrl: u.avatarUrl, size: 46),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              if (u.title.isNotEmpty)
                Text(u.title,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              if (u.cell.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(u.cell,
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.primary,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ])),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1), size: 18),
          ]),
        ),
      );
    },
  );
}

// ── 3-dot menu sheet ──────────────────────────────────────────────────────────
class _MenuSheet extends StatelessWidget {
  final UserModel user;
  final VoidCallback onBlock, onReport;
  final VoidCallback? onRemoveConnection;
  const _MenuSheet({required this.user, required this.onBlock,
      required this.onReport, this.onRemoveConnection});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          AvatarWidget(initials: user.initials, avatarUrl: user.avatarUrl, size: 42),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (user.title.isNotEmpty)
              Text(user.title, style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
          ])),
        ]),
      ),
      const SizedBox(height: 12),
      const Divider(height: 1),
      if (onRemoveConnection != null)
        _MenuItem(icon: Icons.link_off_rounded,
            label: 'Remove Connection',
            color: const Color(0xFF374151),
            onTap: onRemoveConnection!),
      _MenuItem(icon: Icons.flag_outlined,
          label: 'Report ${user.fullName.split(' ').first}',
          color: const Color(0xFF374151),
          onTap: onReport),
      _MenuItem(icon: Icons.block_rounded,
          label: 'Block ${user.fullName.split(' ').first}',
          color: Colors.red,
          onTap: onBlock),
    ]),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label,
      required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color, size: 22),
    title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
    onTap: onTap,
  );
}

// ── Empty ─────────────────────────────────────────────────────────────────────
class _Empty extends StatelessWidget {
  final IconData icon; final String title, sub;
  const _Empty({required this.icon, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 48, color: AppTheme.textSecondary.withOpacity(0.3)),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary)),
      if (sub.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(sub, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    ]),
  );
}