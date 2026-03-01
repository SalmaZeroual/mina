import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../widgets/home/post_card.dart';
import '../../config/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  bool _showFab = true;
  double _lastScroll = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadPosts();
      context.read<NotificationsProvider>().load();
    });
    _scrollCtrl.addListener(() {
      final curr = _scrollCtrl.position.pixels;
      if ((curr - _lastScroll).abs() > 10) {
        setState(() => _showFab = curr < _lastScroll || curr < 80);
        _lastScroll = curr;
      }
    });
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildAppBar(), _buildPostComposer(), _buildFilters()],
        body: Consumer<HomeProvider>(
          builder: (_, home, __) {
            if (home.isLoading && home.posts.isEmpty) return const LoadingWidget();
            if (home.posts.isEmpty) return _EmptyFeed(onPost: _openCreatePost);
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: home.loadPosts,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                itemCount: home.posts.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  child: PostCard(
                    post: home.posts[i],
                    onLike: () => home.toggleLike(home.posts[i].id),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _showFab ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton.extended(
            onPressed: _openCreatePost,
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
            label: const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            elevation: 4,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  SliverAppBar _buildAppBar() {
    final auth = context.read<AuthProvider>();
    return SliverAppBar(
      floating: true, snap: true, pinned: false,
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mina', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -.5)),
        Text(
          auth.currentUser?.cell.isNotEmpty == true ? auth.currentUser!.cell : 'Your Cell',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.normal),
        ),
      ]),
      actions: [
        // Search
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Color(0xFF1A1A2E)),
          tooltip: 'Search',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
        ),
        // Notifications with badge
        Consumer<NotificationsProvider>(builder: (_, np, __) => Stack(children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A2E)),
            tooltip: 'Notifications',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          if (np.unreadCount > 0)
            Positioned(
              right: 8, top: 8,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    np.unreadCount > 9 ? '9+' : '${np.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ])),
        const SizedBox(width: 4),
      ],
    );
  }

  SliverToBoxAdapter _buildPostComposer() {
    final user = context.read<AuthProvider>().currentUser;
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Row(children: [
          AvatarWidget(initials: user?.initials ?? 'U', size: 42, avatarUrl: user?.avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _openCreatePost,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  "What's on your mind?",
                  style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _openCreatePost,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.image_outlined, color: AppTheme.primary, size: 20),
            ),
          ),
        ]),
      ),
    );
  }

  SliverPersistentHeader _buildFilters() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FilterHeaderDelegate(),
    );
  }

  void _openCreatePost() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.pushNamed(context, AppRoutes.createPost);
    if (result == true && mounted) {
      context.read<HomeProvider>().loadPosts();
    }
  }
}

// ── Filter header ────────────────────────────────────────────────────────────
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override double get minExtent => 52;
  @override double get maxExtent => 52;
  @override bool shouldRebuild(_) => false;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Consumer<HomeProvider>(builder: (_, home, __) => Container(
      height: 52,
      color: Colors.white,
      child: Column(children: [
        const Divider(height: 1),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _FilterChip(label: 'All', icon: Icons.home_outlined, filter: FeedFilter.all, current: home.filter),
              _FilterChip(label: 'Posts', icon: Icons.article_outlined, filter: FeedFilter.posts, current: home.filter),
              _FilterChip(label: 'People', icon: Icons.people_outline, filter: FeedFilter.people, current: home.filter),
              _FilterChip(label: 'Groups', icon: Icons.grid_view_outlined, filter: FeedFilter.groups, current: home.filter),
              _FilterChip(label: 'Services', icon: Icons.work_outline, filter: FeedFilter.services, current: home.filter),
            ],
          ),
        ),
      ]),
    ));
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final FeedFilter filter;
  final FeedFilter current;
  const _FilterChip({required this.label, required this.icon, required this.filter, required this.current});

  @override
  Widget build(BuildContext context) {
    final active = filter == current;
    return GestureDetector(
      onTap: () => context.read<HomeProvider>().setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.transparent,
          border: Border.all(color: active ? AppTheme.primary : AppTheme.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: active ? Colors.white : AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────
class _EmptyFeed extends StatelessWidget {
  final VoidCallback onPost;
  const _EmptyFeed({required this.onPost});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.article_outlined, size: 36, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          const Text('Nothing here yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Be the first to share something with your Cell.\nYour post could spark a great conversation.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onPost,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Write the first post'),
          ),
        ]),
      ),
    );
  }
}