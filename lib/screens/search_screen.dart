import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/service_model.dart';
import '../widgets/common/avatar_widget.dart';
import '../widgets/home/post_card.dart';
import '../config/routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _searching = false;

  List<UserModel>    _people   = [];
  List<PostModel>    _posts    = [];
  List<ServiceModel> _services = [];

  final _userSvc = UserService();

  final _trendingTags = [
    '#WebDev', '#UIDesign', '#OpenToWork', '#Flutter',
    '#HealthTech', '#Hiring', '#Collab', '#AI',
  ];
  final _categories = [
    ('💻', 'Web Dev',     '6366F1'),
    ('🏥', 'Medicine',    '14B8A6'),
    ('🎨', 'Design',      'EC4899'),
    ('💰', 'Finance',     'F59E0B'),
    ('⚖️', 'Legal',       '64748B'),
    ('⚙️', 'Engineering', '3B82F6'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() { _query = ''; _searching = false; });
      return;
    }
    setState(() { _query = q; _searching = true; });
    try {
      final results = await Future.wait([
        _userSvc.searchUsers(q),
        _searchPosts(q),
        _searchServices(q),
      ]);
      if (mounted) setState(() {
        _people   = results[0] as List<UserModel>;
        _posts    = results[1] as List<PostModel>;
        _services = results[2] as List<ServiceModel>;
        _searching = false;
      });
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<List<PostModel>> _searchPosts(String q) async {
    try {
      final data = await ApiService.get('/posts/search?q=${Uri.encodeComponent(q)}');
      return (data['data'] as List).map((j) => PostModel.fromJson(j)).toList();
    } catch (_) { return []; }
  }

  Future<List<ServiceModel>> _searchServices(String q) async {
    try {
      final data = await ApiService.get('/services?q=${Uri.encodeComponent(q)}');
      return (data['data'] as List).map((j) => ServiceModel.fromJson(j)).toList();
    } catch (_) { return []; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
              color: const Color(0xFFF0F2F7),
              borderRadius: BorderRadius.circular(20)),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            onChanged: (v) {
              if (v.length >= 2 || v.isEmpty) _search(v);
              else setState(() => _query = v);
            },
            onSubmitted: _search,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search people, posts, services...',
              hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 14),
              prefixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.primary)))
                  : const Icon(Icons.search, size: 18,
                      color: AppTheme.textSecondary),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() { _query = ''; _searching = false; });
                      })
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),
        bottom: _query.isNotEmpty ? TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('People'),
              if (_people.isNotEmpty) ...[
                const SizedBox(width: 4),
                _CountBadge(_people.length),
              ],
            ])),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('Posts'),
              if (_posts.isNotEmpty) ...[
                const SizedBox(width: 4),
                _CountBadge(_posts.length),
              ],
            ])),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('Services'),
              if (_services.isNotEmpty) ...[
                const SizedBox(width: 4),
                _CountBadge(_services.length),
              ],
            ])),
          ],
        ) : null,
      ),
      body: _query.isEmpty ? _buildDiscover() : _buildResults(),
    );
  }

  Widget _buildDiscover() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // Trending tags
      const Text('Trending in your Cell',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
              color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: _trendingTags.map((tag) =>
        GestureDetector(
          onTap: () {
            _searchCtrl.text = tag;
            _search(tag);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(20)),
            child: Text(tag,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppTheme.primary)),
          ),
        )).toList()),

      const SizedBox(height: 24),
      const Text('Explore by category',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
              color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
        childAspectRatio: 2.8,
        children: _categories.map((c) {
          final color = Color(int.parse('FF${c.$3}', radix: 16));
          return GestureDetector(
            onTap: () { _searchCtrl.text = c.$2; _search(c.$2); },
            child: Container(
              decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.2))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(c.$1, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(c.$2,
                    style: TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 13, color: color)),
              ]),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 80),
    ],
  );

  Widget _buildResults() => TabBarView(
    controller: _tabCtrl,
    children: [
      // People
      _people.isEmpty && !_searching
          ? _EmptyResult(query: _query, type: 'people',
              icon: Icons.people_outline)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: _people.length,
              itemBuilder: (_, i) => _PersonCard(user: _people[i]),
            ),
      // Posts
      _posts.isEmpty && !_searching
          ? _EmptyResult(query: _query, type: 'posts',
              icon: Icons.article_outlined)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
              itemCount: _posts.length,
              itemBuilder: (_, i) => PostCard(post: _posts[i]),
            ),
      // Services
      _services.isEmpty && !_searching
          ? _EmptyResult(query: _query, type: 'services',
              icon: Icons.handyman_outlined)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: _services.length,
              itemBuilder: (_, i) => _ServiceCard(service: _services[i]),
            ),
    ],
  );
}

// ── Person card ───────────────────────────────────────────────────────────────
class _PersonCard extends StatefulWidget {
  final UserModel user;
  const _PersonCard({required this.user});
  @override
  State<_PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard> {
  late bool _following;
  bool _loading = false;

  @override
  void initState() { super.initState(); _following = widget.user.isFollowing; }

  Future<void> _toggleFollow() async {
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
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, AppRoutes.userProfile, arguments: u.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9ECF2)),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6, offset: const Offset(0, 2))]),
        child: Row(children: [
          Stack(children: [
            AvatarWidget(initials: u.initials, avatarUrl: u.avatarUrl, size: 50),
            if (u.isOnline)
              Positioned(right: 1, bottom: 1, child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(color: AppTheme.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
              )),
          ]),
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
                    style: const TextStyle(fontSize: 10,
                        color: AppTheme.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ])),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _loading ? null : _toggleFollow,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _following ? Colors.transparent : AppTheme.primary,
                border: Border.all(
                    color: _following ? const Color(0xFFCBD5E1) : AppTheme.primary,
                    width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _loading
                  ? SizedBox(width: 12, height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2,
                          color: _following ? AppTheme.primary : Colors.white))
                  : Text(_following ? 'Following' : 'Follow',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: _following ? AppTheme.textSecondary : Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Service card (mini) ───────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const _ServiceCard({required this.service});

  Color get _color {
    const m = {
      'Web Development': Color(0xFF6366F1), 'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6),        'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6),       'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981),         'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444),
    };
    return m[service.cell] ?? AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pushNamed(
        context, AppRoutes.serviceDetail, arguments: service),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECF2))),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.handyman_outlined, size: 22, color: _color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(service.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('by ${service.provider.fullName}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('\$${service.price.toInt()}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.success, fontSize: 14)),
          if (service.rating > 0)
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
              Text('${service.rating}',
                  style: const TextStyle(fontSize: 11)),
            ]),
        ]),
      ]),
    ),
  );
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge(this.count);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8)),
    child: Text('$count',
        style: const TextStyle(
            fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
  );
}

class _EmptyResult extends StatelessWidget {
  final String query, type; final IconData icon;
  const _EmptyResult({required this.query, required this.type, required this.icon});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 52,
          color: AppTheme.textSecondary.withOpacity(0.3)),
      const SizedBox(height: 16),
      Text('No $type found',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
              color: AppTheme.textSecondary)),
      const SizedBox(height: 6),
      Text('No results for "$query"',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
    ]),
  );
}