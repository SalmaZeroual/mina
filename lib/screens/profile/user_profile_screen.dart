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

// ─────────────────────────────────────────────────────────────────────────────
// USER PROFILE SCREEN — lazy-loaded tabs, fast initial render
// ─────────────────────────────────────────────────────────────────────────────
class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabs;
  final _svc = UserService();

  // State
  UserModel? _user;
  bool _loadingProfile = true;
  bool _actionLoading  = false;

  // Lazy per-tab data
  List<PostModel>  _posts     = [];
  List<UserModel>  _followers = [];
  List<UserModel>  _following = [];
  bool _postsLoaded     = false;
  bool _followersLoaded = false;
  bool _followingLoaded = false;
  bool _postsLoading     = false;
  bool _followersLoading = false;
  bool _followingLoading = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(_onTabChange);
    _loadProfile(); // fast: only profile
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  // ── Load only profile first ──────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    try {
      _user = await _svc.getProfile(widget.userId);
    } catch (_) {}
    if (mounted) {
      setState(() => _loadingProfile = false);
      _loadTabData(0); // pre-load posts tab since it's first
    }
  }

  // ── Tab change = lazy load ────────────────────────────────────────────────────
  void _onTabChange() {
    if (!_tabs.indexIsChanging) _loadTabData(_tabs.index);
  }

  Future<void> _loadTabData(int index) async {
    switch (index) {
      case 0: if (!_postsLoaded && !_postsLoading) _loadPosts(); break;
      case 1: if (!_followersLoaded && !_followersLoading) _loadFollowers(); break;
      case 2: if (!_followingLoaded && !_followingLoading) _loadFollowing(); break;
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _postsLoading = true);
    try {
      final raw = await _svc.getUserPosts(widget.userId);
      _posts = (raw as List)
          .map((j) => PostModel.fromJson(j as Map<String, dynamic>))
          .toList();
      _postsLoaded = true;
    } catch (_) {}
    if (mounted) setState(() => _postsLoading = false);
  }

  Future<void> _loadFollowers() async {
    setState(() => _followersLoading = true);
    try {
      _followers     = await _svc.getFollowers(widget.userId);
      _followersLoaded = true;
    } catch (_) {}
    if (mounted) setState(() => _followersLoading = false);
  }

  Future<void> _loadFollowing() async {
    setState(() => _followingLoading = true);
    try {
      _following     = await _svc.getFollowing(widget.userId);
      _followingLoaded = true;
    } catch (_) {}
    if (mounted) setState(() => _followingLoading = false);
  }

  // ── Refresh without full reload ──────────────────────────────────────────────
  Future<void> _refreshProfile() async {
    try {
      _user = await _svc.getProfile(widget.userId);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  // ── Follow / Unfollow ────────────────────────────────────────────────────────
  Future<void> _toggleFollow() async {
    if (_user == null || _actionLoading) return;
    final wasFollowing = _user!.isFollowing;
    // Optimistic update
    setState(() {
      _actionLoading = true;
      _user = UserModel.fromJson({
        ..._userJson(), 'is_following': !wasFollowing,
        'followers_count': _user!.followersCount + (wasFollowing ? -1 : 1),
      });
    });
    try {
      wasFollowing
          ? await _svc.unfollow(widget.userId)
          : await _svc.follow(widget.userId);
    } catch (_) {
      await _refreshProfile();
    }
    if (mounted) setState(() => _actionLoading = false);
  }

  // ── Connect ──────────────────────────────────────────────────────────────────
  Future<void> _toggleConnect() async {
    if (_user == null || _actionLoading) return;
    setState(() => _actionLoading = true);
    try {
      final u = _user!;
      if (u.isConnected) {
        await _svc.removeConnection(u.id);
        _snack('Connection removed');
      } else if (u.isPendingConnection && u.iAmRequester) {
        await _svc.removeConnection(u.id);
        _snack('Request cancelled');
      } else if (u.isPendingConnection && !u.iAmRequester) {
        await _svc.acceptConnection(u.connectionId!);
        _snack('🎉 You are now connected!');
      } else {
        await _svc.sendConnectionRequest(u.id);
        _snack('Connection request sent');
      }
      await _refreshProfile();
    } catch (e) {
      _snack(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
    if (mounted) setState(() => _actionLoading = false);
  }

  // ── Message ──────────────────────────────────────────────────────────────────
  Future<void> _openMessage() async {
    if (_user == null) return;
    if (!_user!.isConnected) {
      _snack('Connect with this person first to message them');
      return;
    }
    setState(() => _actionLoading = true);
    try {
      final data = await ApiService.post(
          '/messages/conversations/${_user!.id}', {});
      final conv = ConversationModel.fromJson(
          data['data'] as Map<String, dynamic>);
      if (mounted) Navigator.pushNamed(context, AppRoutes.chat, arguments: conv);
    } catch (e) {
      _snack(e.toString(), isError: true);
    }
    if (mounted) setState(() => _actionLoading = false);
  }

  // ── 3-dot menu ───────────────────────────────────────────────────────────────
  void _showMenu() {
    if (_user == null) return;
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _MenuSheet(
        user: _user!,
        onBlock: () async {
          await _svc.blockUser(_user!.id);
          if (mounted) Navigator.pop(context);
          _snack('User blocked');
          if (mounted) Navigator.pop(context); // go back
        },
        onReport: () {
          Navigator.pop(context);
          _snack('Report submitted. Thank you.');
        },
        onRemoveConnection: _user!.isConnected ? () async {
          await _svc.removeConnection(_user!.id);
          Navigator.pop(context);
          _snack('Connection removed');
          await _refreshProfile();
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

  Map<String, dynamic> _userJson() => {
    'id': _user!.id, 'full_name': _user!.fullName, 'email': _user!.email,
    'avatar_url': _user!.avatarUrl, 'initials': _user!.initials,
    'cell_id': _user!.cellId, 'cell': _user!.cell, 'title': _user!.title,
    'location': _user!.location, 'company': _user!.company,
    'about': _user!.about, 'posts_count': _user!.postsCount,
    'followers_count': _user!.followersCount,
    'following_count': _user!.followingCount,
    'is_online': _user!.isOnline, 'is_following': _user!.isFollowing,
    'connection_status': _user!.connectionStatus,
    'connection_id': _user!.connectionId,
    'i_am_requester': _user!.iAmRequester, 'is_blocked': _user!.isBlocked,
    'joined_at': _user!.joinedAt.toIso8601String(),
  };

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
          backgroundColor: Colors.white,
          body: LoadingWidget());
    }
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton()),
        body: const Center(child: Text('User not found')),
      );
    }

    final u    = _user!;
    final myId = context.read<AuthProvider>().currentUser?.id;
    final isMe = myId == u.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildCover(u, isMe)],
        body: Column(children: [
          // Identity card
          _IdentityCard(
            user: u, isMe: isMe, actionLoading: _actionLoading,
            onFollow: _toggleFollow,
            onConnect: _toggleConnect,
            onMessage: _openMessage,
          ),
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              labelColor: AppTheme.primary,
              unselectedLabelColor: const Color(0xFF94A3B8),
              indicatorColor: AppTheme.primary,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'Posts (${_postsLoaded ? _posts.length : u.postsCount})'),
                Tab(text: 'Followers (${_followersLoaded ? _followers.length : u.followersCount})'),
                Tab(text: 'Following (${_followingLoaded ? _following.length : u.followingCount})'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // ── Posts tab ──────────────────────────────────────────────
                _postsLoading
                    ? const _TabLoader()
                    : _posts.isEmpty && _postsLoaded
                        ? _EmptyTab(
                            icon: Icons.article_outlined,
                            title: 'No posts yet',
                            sub: '${u.fullName.split(' ').first} hasn\'t posted anything yet')
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _posts.length,
                            itemBuilder: (_, i) => PostCard(
                              post: _posts[i],
                              onDeleted: () {
                                setState(() => _posts.removeAt(i));
                              },
                            ),
                          ),

                // ── Followers tab ──────────────────────────────────────────
                _followersLoading
                    ? const _TabLoader()
                    : _followers.isEmpty && _followersLoaded
                        ? _EmptyTab(
                            icon: Icons.people_outline,
                            title: 'No followers yet', sub: '')
                        : _UserListTab(
                            users: _followers,
                            onTap: (id) => Navigator.pushNamed(
                                context, AppRoutes.userProfile,
                                arguments: id),
                          ),

                // ── Following tab ──────────────────────────────────────────
                _followingLoading
                    ? const _TabLoader()
                    : _following.isEmpty && _followingLoaded
                        ? _EmptyTab(
                            icon: Icons.person_add_alt_outlined,
                            title: 'Not following anyone', sub: '')
                        : _UserListTab(
                            users: _following,
                            onTap: (id) => Navigator.pushNamed(
                                context, AppRoutes.userProfile,
                                arguments: id),
                          ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ── Cover SliverAppBar ────────────────────────────────────────────────────────
  SliverAppBar _buildCover(UserModel u, bool isMe) {
    final cellColor = _colorFor(u.cell);
    return SliverAppBar(
      expandedHeight: 170,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (!isMe)
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: Colors.white, size: 22),
            onPressed: _showMenu,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(fit: StackFit.expand, children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cellColor,
                  cellColor.withOpacity(0.75),
                  const Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Bottom scrim
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          // Avatar + name
          Positioned(
            bottom: 12, left: 14,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12)]),
                child: Stack(children: [
                  AvatarWidget(
                      initials: u.initials, avatarUrl: u.avatarUrl, size: 62),
                  if (u.isOnline)
                    Positioned(right: 2, bottom: 2,
                      child: Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5)),
                      )),
                ]),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u.fullName,
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w800, fontSize: 18,
                        shadows: [Shadow(blurRadius: 4)])),
                if (u.title.isNotEmpty)
                  Text(u.title, style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 12.5)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Color _colorFor(String? cell) {
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

// ─────────────────────────────────────────────────────────────────────────────
// Identity card
// ─────────────────────────────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final UserModel user;
  final bool isMe, actionLoading;
  final VoidCallback onFollow, onConnect, onMessage;
  const _IdentityCard({
    required this.user, required this.isMe, required this.actionLoading,
    required this.onFollow, required this.onConnect, required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final u = user;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Badges
        if (u.cell.isNotEmpty || u.company != null || u.location != null)
          Wrap(spacing: 6, runSpacing: 6, children: [
            if (u.cell.isNotEmpty)
              _Badge(Icons.grid_view_rounded, u.cell, _colorFor(u.cell)),
            if (u.company != null && u.company!.isNotEmpty)
              _Badge(Icons.business_outlined, u.company!, const Color(0xFF475569)),
            if (u.location != null && u.location!.isNotEmpty)
              _Badge(Icons.location_on_outlined, u.location!, const Color(0xFF475569)),
          ]),

        const SizedBox(height: 12),

        // Stats
        Row(children: [
          _Stat('${u.postsCount}',     'Posts'),
          _divider(),
          _Stat('${u.followersCount}', 'Followers'),
          _divider(),
          _Stat('${u.followingCount}', 'Following'),
        ]),

        if (!isMe) ...[
          const SizedBox(height: 12),
          Row(children: [
            // Connect
            Expanded(flex: 3, child: _ConnectBtn(
                user: u, loading: actionLoading, onTap: onConnect)),
            const SizedBox(width: 8),
            // Follow
            Expanded(flex: 2, child: _FollowBtn(
                isFollowing: u.isFollowing,
                loading: actionLoading, onTap: onFollow)),
            const SizedBox(width: 8),
            // Message
            _MsgBtn(enabled: u.isConnected,
                loading: actionLoading, onTap: onMessage),
          ]),
        ],

        if (u.about != null && u.about!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(u.about!,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B),
                  height: 1.5)),
        ],
      ]),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 32, margin: const EdgeInsets.symmetric(horizontal: 14),
      color: const Color(0xFFE9ECF2));

  Color _colorFor(String? cell) {
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
  const _Badge(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
    decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11.5, color: color,
          fontWeight: FontWeight.w600)),
    ]),
  );
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900,
          fontSize: 17, color: Color(0xFF0F172A))),
      Text(label, style: const TextStyle(fontSize: 11,
          color: Color(0xFF94A3B8))),
    ]),
  );
}

class _ConnectBtn extends StatelessWidget {
  final UserModel user; final bool loading; final VoidCallback onTap;
  const _ConnectBtn({required this.user, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final u = user;
    String label; Color bg; Color fg; IconData icon;
    if (u.isConnected) {
      label = 'Connected'; bg = AppTheme.success.withOpacity(0.1);
      fg = AppTheme.success; icon = Icons.check_circle_outline;
    } else if (u.isPendingConnection && u.iAmRequester) {
      label = 'Requested'; bg = const Color(0xFFF59E0B).withOpacity(0.1);
      fg = const Color(0xFFF59E0B); icon = Icons.schedule_rounded;
    } else if (u.isPendingConnection && !u.iAmRequester) {
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
            color: bg, borderRadius: BorderRadius.circular(20),
            boxShadow: bg == AppTheme.primary ? [BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 8, offset: const Offset(0, 3))] : null),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          loading
              ? SizedBox(width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg))
              : Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w700, color: fg)),
        ]),
      ),
    );
  }
}

class _FollowBtn extends StatelessWidget {
  final bool isFollowing, loading; final VoidCallback onTap;
  const _FollowBtn({required this.isFollowing, required this.loading,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 40,
      decoration: BoxDecoration(
        color: isFollowing ? Colors.transparent : AppTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isFollowing ? const Color(0xFFCBD5E1) : AppTheme.primary,
            width: 1.5),
      ),
      child: Center(child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: isFollowing ? const Color(0xFF94A3B8) : AppTheme.primary))),
    ),
  );
}

class _MsgBtn extends StatelessWidget {
  final bool enabled, loading; final VoidCallback onTap;
  const _MsgBtn({required this.enabled, required this.loading, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: enabled
            ? AppTheme.primary.withOpacity(0.08)
            : Colors.grey.withOpacity(0.07),
        shape: BoxShape.circle,
        border: Border.all(
            color: enabled ? AppTheme.primary : const Color(0xFFDDE1E9),
            width: 1.5),
      ),
      child: Icon(Icons.chat_bubble_outline_rounded,
          size: 17,
          color: enabled ? AppTheme.primary : const Color(0xFFCBD5E1)),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// User list tab
// ─────────────────────────────────────────────────────────────────────────────
class _UserListTab extends StatelessWidget {
  final List<UserModel> users;
  final ValueChanged<String> onTap;
  const _UserListTab({required this.users, required this.onTap});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 80),
    itemCount: users.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (_, i) {
      final u = users[i];
      return GestureDetector(
        onTap: () => onTap(u.id),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEF0F5))),
          child: Row(children: [
            Stack(children: [
              AvatarWidget(initials: u.initials, avatarUrl: u.avatarUrl, size: 46),
              if (u.isOnline)
                Positioned(right: 1, bottom: 1,
                  child: Container(width: 11, height: 11,
                    decoration: BoxDecoration(color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                  )),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.fullName, style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
              if (u.title.isNotEmpty)
                Text(u.title, style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 12.5),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              if (u.cell.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(7)),
                  child: Text(u.cell, style: const TextStyle(
                      fontSize: 10.5, color: AppTheme.primary,
                      fontWeight: FontWeight.w700)),
                ),
              ],
            ])),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFFCBD5E1)),
          ]),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 3-dot menu
// ─────────────────────────────────────────────────────────────────────────────
class _MenuSheet extends StatelessWidget {
  final UserModel user;
  final VoidCallback onBlock, onReport;
  final VoidCallback? onRemoveConnection;
  const _MenuSheet({required this.user, required this.onBlock,
      required this.onReport, this.onRemoveConnection});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 12),
      Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          AvatarWidget(initials: user.initials, avatarUrl: user.avatarUrl, size: 44),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(user.fullName, style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15)),
            if (user.title.isNotEmpty)
              Text(user.title, style: const TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 12.5)),
          ]),
        ]),
      ),
      const Divider(height: 1),
      if (onRemoveConnection != null)
        _Item(Icons.link_off_rounded, 'Remove Connection',
            const Color(0xFF374151), onRemoveConnection!),
      _Item(Icons.flag_outlined, 'Report ${user.fullName.split(' ').first}',
          const Color(0xFF374151), onReport),
      _Item(Icons.block_rounded, 'Block ${user.fullName.split(' ').first}',
          Colors.red, onBlock),
    ]),
  );
}

class _Item extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  final VoidCallback onTap;
  const _Item(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 19),
    ),
    title: Text(label, style: TextStyle(color: color,
        fontWeight: FontWeight.w600, fontSize: 14)),
    onTap: onTap, dense: true,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _TabLoader extends StatelessWidget {
  const _TabLoader();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.only(top: 60),
      child: CircularProgressIndicator(
          strokeWidth: 2.5, color: AppTheme.primary),
    ),
  );
}

class _EmptyTab extends StatelessWidget {
  final IconData icon; final String title, sub;
  const _EmptyTab({required this.icon, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 52,
          color: const Color(0xFF94A3B8).withOpacity(0.4)),
      const SizedBox(height: 14),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700,
          fontSize: 15, color: Color(0xFF94A3B8))),
      if (sub.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(sub, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1))),
      ],
    ]),
  );
}