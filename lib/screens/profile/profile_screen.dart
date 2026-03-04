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

// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<UserModel> _connections = [];
  bool _loadingConnections = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.id;
      if (uid != null) {
        context.read<ProfileProvider>().loadProfile(uid);
        _fetchConnections(uid);
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _fetchConnections(String uid) async {
    setState(() => _loadingConnections = true);
    try {
      _connections = await UserService().getFollowing(uid);
    } catch (_) {}
    if (mounted) setState(() => _loadingConnections = false);
  }

  void _reload() {
    final uid = context.read<AuthProvider>().currentUser?.id;
    if (uid != null) {
      context.read<ProfileProvider>().loadProfile(uid);
      _fetchConnections(uid);
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
          headerSliverBuilder: (ctx, _) => [_buildAppBar(ctx, u)],
          body: Column(children: [
            // ── Card identité ─────────────────────────────────────────────
            _IdentityCard(user: u, onEdit: _reload),
            const SizedBox(height: 8),
            // ── Tabs ──────────────────────────────────────────────────────
            _TabBar(controller: _tabs),
            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _PostsTab(posts: pp.userPosts),
                  _ConnectionsTab(
                    connections: _connections,
                    loading: _loadingConnections,
                  ),
                  _AboutTab(user: u),
                ],
              ),
            ),
          ]),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      );
    });
  }

  SliverAppBar _buildAppBar(BuildContext context, UserModel u) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: null,
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
          // Gradient cover
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _cellColor(u.cell),
                  _cellColor(u.cell).withOpacity(0.7),
                  const Color(0xFF1A1A2E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Subtle pattern overlay
          Opacity(
            opacity: 0.06,
            child: Image.network(
              'https://www.transparenttextures.com/patterns/diagmonds.png',
              repeat: ImageRepeat.repeat,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // Bottom scrim
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0x88000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SizedBox(height: 60),
            ),
          ),
          // Name on cover (visible when collapsed)
          Positioned(
            bottom: 14, left: 72,
            child: Text(u.fullName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          // Avatar on cover
          Positioned(
            bottom: 4, left: 16,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.25),
                      blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: AvatarWidget(
                  initials: u.initials, avatarUrl: u.avatarUrl, size: 72),
            ),
          ),
        ]),
      ),
    );
  }

  Color _cellColor(String? cell) {
    const m = {
      'Web Development': Color(0xFF6366F1),
      'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6),
      'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6),
      'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981),
      'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444),
      'Photography': Color(0xFFF97316),
    };
    return m[cell] ?? AppTheme.primary;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Identity card
// ─────────────────────────────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  const _IdentityCard({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Name + title
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(user.fullName,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3)),
            if (user.title.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(user.title,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.3)),
            ],
          ])),
          // Edit button
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile)
                .then((_) => onEdit()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary, width: 1.5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.edit_outlined, size: 15, color: AppTheme.primary),
                SizedBox(width: 6),
                Text('Edit',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
              ]),
            ),
          ),
        ]),

        const SizedBox(height: 12),

        // Meta badges
        Wrap(spacing: 8, runSpacing: 6, children: [
          if (user.cell.isNotEmpty)
            _MetaBadge(
                icon: Icons.grid_view_rounded,
                label: user.cell,
                color: _cellColor(user.cell)),
          if (user.company != null && user.company!.isNotEmpty)
            _MetaBadge(
                icon: Icons.business_outlined,
                label: user.company!,
                color: const Color(0xFF374151)),
          if (user.location != null && user.location!.isNotEmpty)
            _MetaBadge(
                icon: Icons.location_on_outlined,
                label: user.location!,
                color: const Color(0xFF374151)),
        ]),

        const SizedBox(height: 16),

        // Stats row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _StatPill(
                value: _fmt(user.postsCount),
                label: 'Posts',
                icon: Icons.article_outlined),
            _Divider(),
            _StatPill(
                value: _fmt(user.followersCount),
                label: 'Followers',
                icon: Icons.people_outline),
            _Divider(),
            _StatPill(
                value: _fmt(user.followingCount),
                label: 'Following',
                icon: Icons.person_add_alt_outlined),
          ]),
        ),

        // About preview
        if (user.about != null && user.about!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(user.about!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.6)),
        ],
      ]),
    );
  }

  Color _cellColor(String? cell) {
    const m = {
      'Web Development': Color(0xFF6366F1),
      'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6),
      'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6),
      'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981),
      'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444),
    };
    return m[cell] ?? AppTheme.primary;
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600)),
    ]),
  );
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatPill({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 17, color: AppTheme.primary),
    const SizedBox(height: 5),
    Text(value,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Color(0xFF0F172A))),
    Text(label,
        style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500)),
  ]);
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 38, color: const Color(0xFFE2E8F0));
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom tab bar
// ─────────────────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    child: TabBar(
      controller: controller,
      labelColor: AppTheme.primary,
      unselectedLabelColor: AppTheme.textSecondary,
      indicatorColor: AppTheme.primary,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      tabs: const [
        Tab(text: 'Posts'),
        Tab(text: 'Network'),
        Tab(text: 'About'),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Posts tab
// ─────────────────────────────────────────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final List posts;
  const _PostsTab({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return _EmptyState(
        icon: Icons.article_outlined,
        title: 'No posts yet',
        sub: 'Share your knowledge with the community',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
      itemCount: posts.length,
      itemBuilder: (_, i) => PostCard(post: posts[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Connections tab
// ─────────────────────────────────────────────────────────────────────────────
class _ConnectionsTab extends StatelessWidget {
  final List<UserModel> connections;
  final bool loading;
  const _ConnectionsTab({required this.connections, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (connections.isEmpty) {
      return _EmptyState(
        icon: Icons.people_outline,
        title: 'No connections yet',
        sub: 'Follow professionals to grow your network',
        actionLabel: 'Explore people',
        onAction: () => Navigator.pushNamed(context, AppRoutes.search),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: connections.length,
      itemBuilder: (_, i) => _ConnectionCard(user: connections[i]),
    );
  }
}

class _ConnectionCard extends StatefulWidget {
  final UserModel user;
  const _ConnectionCard({required this.user});

  @override
  State<_ConnectionCard> createState() => _ConnectionCardState();
}

class _ConnectionCardState extends State<_ConnectionCard> {
  bool _following = true;
  bool _loading = false;

  Future<void> _toggle() async {
    setState(() => _loading = true);
    try {
      if (_following) {
        await UserService().unfollow(widget.user.id);
      } else {
        await UserService().follow(widget.user.id);
      }
      setState(() => _following = !_following);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECF2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        // Avatar with online dot
        Stack(children: [
          AvatarWidget(
              initials: u.initials, avatarUrl: u.avatarUrl, size: 50),
          if (u.isOnline)
            Positioned(
              right: 1, bottom: 1,
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
              ),
            ),
        ]),
        const SizedBox(width: 12),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(u.fullName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF0F172A))),
          if (u.title.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(u.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ],
          if (u.cell.isNotEmpty) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(u.cell,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ])),

        const SizedBox(width: 10),

        // Follow / Unfollow button
        GestureDetector(
          onTap: _loading ? null : _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _following ? Colors.transparent : AppTheme.primary,
              border: Border.all(
                  color: _following
                      ? const Color(0xFFCBD5E1)
                      : AppTheme.primary,
                  width: 1.5),
              borderRadius: BorderRadius.circular(22),
            ),
            child: _loading
                ? SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _following
                            ? AppTheme.primary
                            : Colors.white))
                : Text(
                    _following ? 'Following' : 'Follow',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _following
                            ? AppTheme.textSecondary
                            : Colors.white),
                  ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// About tab
// ─────────────────────────────────────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  final UserModel user;
  const _AboutTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(children: [
        // Bio card
        if (user.about != null && user.about!.isNotEmpty)
          _AboutCard(
            title: 'Bio',
            icon: Icons.format_quote_outlined,
            child: Text(user.about!,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.7)),
          ),

        // Professional info
        _AboutCard(
          title: 'Professional',
          icon: Icons.work_outline_rounded,
          child: Column(children: [
            _AboutRow(
                icon: Icons.grid_view_rounded,
                label: 'Domain / Cell',
                value: user.cell.isNotEmpty ? user.cell : '—'),
            _AboutRow(
                icon: Icons.badge_outlined,
                label: 'Title',
                value: user.title.isNotEmpty ? user.title : '—'),
            _AboutRow(
                icon: Icons.business_outlined,
                label: 'Company',
                value: user.company ?? '—'),
          ]),
        ),

        // Personal info
        _AboutCard(
          title: 'Personal',
          icon: Icons.person_outline,
          child: Column(children: [
            _AboutRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: user.location ?? '—'),
            _AboutRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email),
            _AboutRow(
                icon: Icons.calendar_today_outlined,
                label: 'Member since',
                value: _fmtDate(user.joinedAt)),
          ]),
        ),
      ]),
    );
  }

  String _fmtDate(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

class _AboutCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _AboutCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE9ECF2)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2)),
      ],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0F172A))),
        ]),
      ),
      Divider(height: 1, color: const Color(0xFFE9ECF2)),
      Padding(padding: const EdgeInsets.all(16), child: child),
    ]),
  );
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _AboutRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 17, color: AppTheme.textSecondary),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: value == '—'
                    ? AppTheme.textSecondary
                    : const Color(0xFF0F172A))),
      ])),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.sub,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(36),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
              color: AppTheme.textSecondary.withOpacity(0.08),
              shape: BoxShape.circle),
          child: Icon(icon, size: 32,
              color: AppTheme.textSecondary.withOpacity(0.4)),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF374151))),
        const SizedBox(height: 6),
        Text(sub,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5)),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 20),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primary.withOpacity(0.08),
              foregroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
            ),
            child: Text(actionLabel!,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ]),
    ),
  );
}