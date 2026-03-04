import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/search_service.dart';
import '../widgets/common/avatar_widget.dart';
import '../widgets/home/post_card.dart';
import '../providers/home_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _ctrl   = TextEditingController();
  final _debounce = ValueNotifier<String>('');

  SearchResult? _results;
  bool _loading = false;
  String _query  = '';

  static const _tabs = ['All', 'People', 'Posts', 'Groups', 'Services'];
  static const _trendingTags = ['#WebDev','#UIDesign','#OpenToWork','#Flutter','#HealthTech','#Hiring','#Collab','#AI'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _ctrl.addListener(() {
      final q = _ctrl.text.trim();
      if (q == _query) return;
      _query = q;
      if (q.isEmpty) { setState(() { _results = null; _loading = false; }); return; }
      _triggerSearch(q);
    });
  }

  @override
  void dispose() { _tab.dispose(); _ctrl.dispose(); super.dispose(); }

  Future<void> _triggerSearch(String q) async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 400)); // debounce
    if (_ctrl.text.trim() != q) return; // stale
    try {
      final res = await SearchService_.search(q);
      if (mounted) setState(() { _results = res; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40, margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
          child: TextField(
            controller: _ctrl, autofocus: true,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search people, posts, groups...',
              hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(.7), fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () { _ctrl.clear(); setState(() { _query = ''; _results = null; }); })
                  : null,
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tab, isScrollable: true,
          labelColor: AppTheme.primary, unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary, indicatorWeight: 2,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _query.isEmpty
          ? _buildDiscover()
          : _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _results == null
                  ? const SizedBox.shrink()
                  : TabBarView(
                      controller: _tab,
                      children: [
                        _AllTab(results: _results!),
                        _PeopleTab(people: _results!.people),
                        _PostsTab(posts: _results!.posts),
                        _GroupsTab(groups: _results!.groups),
                        _ServicesTab(services: _results!.services),
                      ],
                    ),
    );
  }

  Widget _buildDiscover() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Trending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    const SizedBox(height: 12),
    Wrap(spacing: 8, runSpacing: 8, children: _trendingTags.map((tag) => GestureDetector(
      onTap: () { _ctrl.text = tag; },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(20)),
        child: Text(tag, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primary)),
      ),
    )).toList()),
    const SizedBox(height: 28),
    const Text('Browse by Cell', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    const SizedBox(height: 12),
    GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.8,
      children: [
        _CatCard(emoji: '💻', label: 'Web Dev',     color: const Color(0xFFEEF2FF)),
        _CatCard(emoji: '🏥', label: 'Medicine',    color: const Color(0xFFF0FDF4)),
        _CatCard(emoji: '🎨', label: 'Design',      color: const Color(0xFFFFF0F8)),
        _CatCard(emoji: '💰', label: 'Finance',     color: const Color(0xFFFFFBEB)),
        _CatCard(emoji: '⚖️', label: 'Legal',       color: const Color(0xFFF5F3FF)),
        _CatCard(emoji: '⚙️', label: 'Engineering', color: const Color(0xFFEFF6FF)),
      ],
    ),
  ]);
}

// ── All tab ──────────────────────────────────────────────────────────────────
class _AllTab extends StatelessWidget {
  final SearchResult results;
  const _AllTab({required this.results});
  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return _EmptySearch();
    return ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
      if (results.people.isNotEmpty) ...[
        _SectionHeader(label: 'People', count: results.people.length),
        ...results.people.take(3).map((p) => _PersonTile(person: p)),
      ],
      if (results.posts.isNotEmpty) ...[
        _SectionHeader(label: 'Posts', count: results.posts.length),
        ...results.posts.take(2).map((p) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: PostCard(post: p, onLike: () => context.read<HomeProvider>().toggleLike(p.id)),
        )),
      ],
      if (results.groups.isNotEmpty) ...[
        _SectionHeader(label: 'Groups', count: results.groups.length),
        ...results.groups.take(2).map((g) => _GroupTile(group: g)),
      ],
      if (results.services.isNotEmpty) ...[
        _SectionHeader(label: 'Services', count: results.services.length),
        ...results.services.take(2).map((s) => _ServiceTile(service: s)),
      ],
    ]);
  }
}

// ── People tab ───────────────────────────────────────────────────────────────
class _PeopleTab extends StatelessWidget {
  final List<SearchUser> people;
  const _PeopleTab({required this.people});
  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return _EmptySearch();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: people.length,
      itemBuilder: (_, i) => _PersonTile(person: people[i]),
    );
  }
}

// ── Posts tab ────────────────────────────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final posts;
  const _PostsTab({required this.posts});
  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return _EmptySearch();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: PostCard(post: posts[i], onLike: () => context.read<HomeProvider>().toggleLike(posts[i].id)),
      ),
    );
  }
}

// ── Groups tab ───────────────────────────────────────────────────────────────
class _GroupsTab extends StatelessWidget {
  final List<SearchGroup> groups;
  const _GroupsTab({required this.groups});
  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return _EmptySearch();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groups.length,
      itemBuilder: (_, i) => _GroupTile(group: groups[i]),
    );
  }
}

// ── Services tab ─────────────────────────────────────────────────────────────
class _ServicesTab extends StatelessWidget {
  final List<SearchService> services;
  const _ServicesTab({required this.services});
  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return _EmptySearch();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: services.length,
      itemBuilder: (_, i) => _ServiceTile(service: services[i]),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label; final int count;
  const _SectionHeader({required this.label, required this.count});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
    child: Row(children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
        child: Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
      ),
    ]),
  );
}

class _PersonTile extends StatefulWidget {
  final SearchUser person;
  const _PersonTile({required this.person});
  @override
  State<_PersonTile> createState() => _PersonTileState();
}

class _PersonTileState extends State<_PersonTile> {
  late bool _following;
  bool _loading = false;

  @override
  void initState() { super.initState(); _following = widget.person.isFollowing; }

  Future<void> _toggle() async {
    setState(() => _loading = true);
    try {
      final result = await SearchService_.toggleFollow(widget.person.id);
      setState(() { _following = result; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(children: [
      AvatarWidget(initials: widget.person.initials, size: 46, avatarUrl: widget.person.avatarUrl),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.person.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        if (widget.person.title.isNotEmpty)
          Text(widget.person.title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        if (widget.person.cell.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(.08), borderRadius: BorderRadius.circular(10),
            ),
            child: Text(widget.person.cell, style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
      ])),
      const SizedBox(width: 8),
      _loading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
          : _following
              ? OutlinedButton(
                  onPressed: _toggle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.border),
                    minimumSize: const Size(80, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Following', style: TextStyle(fontSize: 12)),
                )
              : ElevatedButton(
                  onPressed: _toggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size(80, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Follow', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
    ]),
  );
}

class _GroupTile extends StatelessWidget {
  final SearchGroup group;
  const _GroupTile({required this.group});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(children: [
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.grid_view_rounded, color: AppTheme.primary, size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          if (group.isPrivate) const Icon(Icons.lock_outline, size: 14, color: AppTheme.textSecondary),
        ]),
        Text('${group.membersCount} members · ${group.cell}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ])),
      const SizedBox(width: 8),
      group.isMember
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(.1), borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Joined', style: TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.w600)),
            )
          : ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary, minimumSize: const Size(72, 32),
                padding: const EdgeInsets.symmetric(horizontal: 14), elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(group.isPrivate ? 'Request' : 'Join', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
    ]),
  );
}

class _ServiceTile extends StatelessWidget {
  final SearchService service;
  const _ServiceTile({required this.service});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(children: [
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.work_outline, color: Color(0xFFF59E0B), size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(service.provider['full_name'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        if (service.avgRating > 0)
          Row(children: [
            const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
            const SizedBox(width: 2),
            Text('${service.avgRating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(' (${service.reviewsCount})', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ]),
      ])),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('\$${service.price.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary)),
        Text(service.priceType, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ]),
    ]),
  );
}

class _CatCard extends StatelessWidget {
  final String emoji, label; final Color color;
  const _CatCard({required this.emoji, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
    ]),
  );
}

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.search_off_rounded, size: 52, color: AppTheme.textSecondary.withOpacity(.4)),
    const SizedBox(height: 16),
    const Text('No results found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Try different keywords', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
  ]));
}