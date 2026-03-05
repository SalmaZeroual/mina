import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../widgets/home/post_card.dart';
import '../../services/user_service.dart';
import '../../config/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabs;

  // Lazy per-tab
  List<UserModel> _network     = [];
  bool _networkLoaded  = false;
  bool _networkLoading = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(_onTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.id;
      if (uid != null) context.read<ProfileProvider>().loadProfile(uid);
    });
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  void _onTabChange() {
    if (!_tabs.indexIsChanging && _tabs.index == 1) _loadNetwork();
  }

  Future<void> _loadNetwork() async {
    if (_networkLoaded || _networkLoading) return;
    final uid = context.read<AuthProvider>().currentUser?.id;
    if (uid == null) return;
    setState(() => _networkLoading = true);
    try {
      _network = await UserService().getUserConnections(uid);
      _networkLoaded = true;
    } catch (_) {}
    if (mounted) setState(() => _networkLoading = false);
  }

  void _reload() {
    final uid = context.read<AuthProvider>().currentUser?.id;
    if (uid != null) {
      context.read<ProfileProvider>().loadProfile(uid);
      if (_networkLoaded) {
        _networkLoaded = false;
        _loadNetwork();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(builder: (_, pp, __) {
      if (pp.isLoading || pp.user == null) {
        return const Scaffold(
          body: LoadingWidget(),
          bottomNavigationBar: BottomNavBar(currentIndex: 4),
        );
      }
      final u = pp.user!;

      return Scaffold(
        backgroundColor: const Color(0xFFF2F3F7),
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [_buildCover(ctx, u)],
          body: Column(children: [
            _IdentityCard(user: u, onEdit: _reload),
            const SizedBox(height: 8),
            _buildTabBar(u),
            Expanded(child: TabBarView(
              controller: _tabs,
              children: [
                _PostsTab(posts: pp.userPosts),
                _NetworkTab(users: _network, loading: _networkLoading, loaded: _networkLoaded),
                _AboutTab(user: u),
              ],
            )),
          ]),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      );
    });
  }

  Widget _buildTabBar(UserModel u) => Container(
    color: Colors.white,
    child: TabBar(
      controller: _tabs,
      labelColor: AppTheme.primary,
      unselectedLabelColor: AppTheme.textSecondary,
      indicatorColor: AppTheme.primary,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      tabs: [
        const Tab(text: 'Posts'),
        Tab(text: 'Network (${_networkLoaded ? _network.length : u.connectionsCount})'),
        const Tab(text: 'About'),
      ],
    ),
  );

  SliverAppBar _buildCover(BuildContext context, UserModel u) {
    final color = _cellColor(u.cell);
    return SliverAppBar(
      expandedHeight: 180, pinned: true,
      backgroundColor: Colors.white, elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.settings).then((_) => _reload()),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(fit: StackFit.expand, children: [
          Container(decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7), const Color(0xFF1A1A2E)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          )),
          const Positioned(bottom: 0, left: 0, right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: LinearGradient(
                colors: [Colors.transparent, Color(0x88000000)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              )),
              child: SizedBox(height: 60),
            )),
          Positioned(bottom: 14, left: 72,
            child: Text(u.fullName, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
          Positioned(bottom: 4, left: 16,
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25),
                    blurRadius: 12, offset: const Offset(0, 4))]),
              child: AvatarWidget(initials: u.initials, avatarUrl: u.avatarUrl, size: 72),
            )),
        ]),
      ),
    );
  }

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

// ─── Identity Card ────────────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  const _IdentityCard({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final u = user;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(u.fullName, style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A), letterSpacing: -0.3)),
            if (u.title.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(u.title, style: const TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary, height: 1.3)),
            ],
          ])),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile)
                .then((_) => onEdit()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(22)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.edit_outlined, size: 15, color: AppTheme.primary),
                SizedBox(width: 6),
                Text('Edit', style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 6, children: [
          if (u.cell.isNotEmpty)
            _Badge(Icons.grid_view_rounded, u.cell, _cellColor(u.cell)),
          if (u.company != null && u.company!.isNotEmpty)
            _Badge(Icons.business_outlined, u.company!, const Color(0xFF374151)),
          if (u.location != null && u.location!.isNotEmpty)
            _Badge(Icons.location_on_outlined, u.location!, const Color(0xFF374151)),
        ]),
        const SizedBox(height: 16),
        // Stats — clickable
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _Stat(value: _fmt(u.postsCount),      label: 'Posts',
                icon: Icons.article_outlined,       onTap: null),
            _StatDivider(),
            _Stat(value: _fmt(u.followersCount),  label: 'Followers',
                icon: Icons.people_outline,
                onTap: () => _showFollowers(context, initialTab: 0)),
            _StatDivider(),
            _Stat(value: _fmt(u.followingCount),  label: 'Following',
                icon: Icons.person_add_alt_outlined,
                onTap: () => _showFollowers(context, initialTab: 1)),
          ]),
        ),
      ]),
    );
  }

  void _showFollowers(BuildContext context, {int initialTab = 0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FollowersSheet(userId: user.id, initialTab: initialTab),
    );
  }

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

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _Badge extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _Badge(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color), const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _Stat extends StatelessWidget {
  final String value, label; final IconData icon; final VoidCallback? onTap;
  const _Stat({required this.value, required this.label, required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Icon(icon, size: 17, color: AppTheme.primary),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F172A))),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
          color: onTap != null ? AppTheme.primary : AppTheme.textSecondary)),
    ]),
  );
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 38, color: const Color(0xFFE2E8F0));
}

// ─── Network Tab ──────────────────────────────────────────────────────────────
class _NetworkTab extends StatelessWidget {
  final List<UserModel> users;
  final bool loading, loaded;
  const _NetworkTab({required this.users, required this.loading, required this.loaded});

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5));
    if (users.isEmpty && loaded) return _EmptyState(
      icon: Icons.people_outline,
      title: 'No connections yet',
      sub: 'Connect with people in your Cell to grow your network',
      actionLabel: 'Find people',
      onAction: () => Navigator.pushNamed(context, AppRoutes.search),
    );
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: users.length,
      itemBuilder: (_, i) => _NetworkCard(user: users[i]),
    );
  }
}

class _NetworkCard extends StatelessWidget {
  final UserModel user;
  const _NetworkCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final u = user;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile, arguments: u.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECF2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Stack(children: [
            AvatarWidget(initials: u.initials, avatarUrl: u.avatarUrl, size: 50),
            if (u.isOnline) Positioned(right: 1, bottom: 1,
              child: Container(width: 12, height: 12,
                decoration: BoxDecoration(color: AppTheme.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
              )),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(u.fullName, style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            if (u.title.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(u.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
            if (u.cell.isNotEmpty) ...[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(u.cell, style: const TextStyle(
                    fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ])),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: Color(0xFFCBD5E1)),
        ]),
      ),
    );
  }
}

// ─── Posts Tab ────────────────────────────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final List posts;
  const _PostsTab({required this.posts});
  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return _EmptyState(
      icon: Icons.article_outlined, title: 'No posts yet',
      sub: 'Share your knowledge with the community',
    );
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
      itemCount: posts.length,
      itemBuilder: (_, i) => PostCard(post: posts[i], onDeleted: () {}),
    );
  }
}

// ─── About Tab ────────────────────────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  final UserModel user;
  const _AboutTab({required this.user});
  @override
  Widget build(BuildContext context) {
    final u = user;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(children: [
        if (u.about != null && u.about!.isNotEmpty)
          _AboutCard(title: 'Bio', icon: Icons.format_quote_outlined,
            child: Text(u.about!, style: const TextStyle(
                fontSize: 14, color: AppTheme.textSecondary, height: 1.7))),
        _AboutCard(title: 'Professional', icon: Icons.work_outline_rounded,
          child: Column(children: [
            _Row(Icons.grid_view_rounded, 'Cell', u.cell.isNotEmpty ? u.cell : '—'),
            _Row(Icons.badge_outlined,    'Title', u.title.isNotEmpty ? u.title : '—'),
            _Row(Icons.business_outlined, 'Company', u.company ?? '—'),
          ])),
        _AboutCard(title: 'Personal', icon: Icons.person_outline,
          child: Column(children: [
            _Row(Icons.location_on_outlined, 'Location', u.location ?? '—'),
            _Row(Icons.email_outlined,       'Email',    u.email),
            _Row(Icons.calendar_today_outlined, 'Member since', _fmtDate(u.joinedAt)),
          ])),
        // Network visibility setting
        _AboutCard(title: 'Privacy', icon: Icons.lock_outline_rounded,
          child: Column(children: [
            _Row(Icons.people_outline, 'Network visibility',
              _visLabel(u.networkVisibility)),
            const SizedBox(height: 4),
            Text('Control who can see your connections',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
      ]),
    );
  }

  String _visLabel(String v) {
    if (v == 'connections_only') return 'Connections only';
    if (v == 'private') return 'Private';
    return 'Public';
  }

  String _fmtDate(DateTime dt) {
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

class _AboutCard extends StatelessWidget {
  final String title; final IconData icon; final Widget child;
  const _AboutCard({required this.title, required this.icon, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECF2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02),
            blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Row(children: [
          Container(width: 32, height: 32,
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: AppTheme.primary)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold,
              fontSize: 15, color: Color(0xFF0F172A))),
        ]),
      ),
      const Divider(height: 1, color: Color(0xFFE9ECF2)),
      Padding(padding: const EdgeInsets.all(16), child: child),
    ]),
  );
}

class _Row extends StatelessWidget {
  final IconData icon; final String label, value;
  const _Row(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 17, color: AppTheme.textSecondary),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11,
            color: AppTheme.textSecondary, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
            color: value == '—' ? AppTheme.textSecondary : const Color(0xFF0F172A))),
      ])),
    ]),
  );
}

// ─── Followers sheet (modal) ───────────────────────────────────────────────────
class _FollowersSheet extends StatefulWidget {
  final String userId;
  final int initialTab;
  const _FollowersSheet({required this.userId, this.initialTab = 0});
  @override
  State<_FollowersSheet> createState() => _FollowersSheetState();
}

class _FollowersSheetState extends State<_FollowersSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<UserModel> _followers = [], _following = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    final svc = UserService();
    final results = await Future.wait([
      svc.getFollowers(widget.userId),
      svc.getFollowing(widget.userId),
    ]);
    if (mounted) setState(() {
      _followers = results[0]; _following = results[1]; _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * 0.75,
    decoration: const BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    child: Column(children: [
      const SizedBox(height: 12),
      Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 8),
      TabBar(
        controller: _tabs,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          Tab(text: 'Followers (${_followers.length})'),
          Tab(text: 'Following (${_following.length})'),
        ],
      ),
      Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(controller: _tabs, children: [
              _UserList(users: _followers),
              _UserList(users: _following),
            ])),
    ]),
  );
}

class _UserList extends StatelessWidget {
  final List<UserModel> users;
  const _UserList({required this.users});
  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const Center(
      child: Text('No users', style: TextStyle(color: AppTheme.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final u = users[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AvatarWidget(initials: u.initials, avatarUrl: u.avatarUrl, size: 44),
          title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: u.title.isNotEmpty ? Text(u.title) : null,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.userProfile, arguments: u.id);
          },
        );
      },
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon; final String title, sub;
  final String? actionLabel; final VoidCallback? onAction;
  const _EmptyState({required this.icon, required this.title, required this.sub,
      this.actionLabel, this.onAction});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(36),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 72, height: 72,
          decoration: BoxDecoration(
              color: AppTheme.textSecondary.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(icon, size: 32, color: AppTheme.textSecondary.withOpacity(0.4))),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold,
            fontSize: 16, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        Text(sub, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 20),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
                backgroundColor: AppTheme.primary.withOpacity(0.08),
                foregroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10)),
            child: Text(actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ]),
    ),
  );
}