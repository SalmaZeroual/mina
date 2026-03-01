import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common/avatar_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _isSearching = false;

  final _tabs = const ['All', 'Posts', 'People', 'Groups', 'Services'];

  final _trendingTags = ['#WebDev', '#UIDesign', '#OpenToWork', '#Flutter', '#HealthTech', '#Hiring', '#Collab', '#AI'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            onChanged: (v) => setState(() { _query = v; _isSearching = v.trim().isNotEmpty; }),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search posts, people, groups...',
              hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () { _searchCtrl.clear(); setState(() { _query = ''; _isSearching = false; }); })
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 2,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _query.isEmpty ? _buildDiscover() : _buildResults(),
    );
  }

  Widget _buildDiscover() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Trending tags
      const Text('Trending in your Cell', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: _trendingTags.map((tag) => GestureDetector(
        onTap: () { _searchCtrl.text = tag; setState(() { _query = tag; _isSearching = true; }); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white, border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(tag, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primary)),
        ),
      )).toList()),

      const SizedBox(height: 28),
      const Text('Explore by category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 12),
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.5,
        children: _categoryCards,
      ),

      const SizedBox(height: 28),
      const Text('Suggested people in your Cell', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 12),
      ..._suggestedPeople.map((p) => _PersonTile(name: p['name']!, role: p['role']!, initials: p['initials']!, color: p['color']!)),
    ]);
  }

  Widget _buildResults() {
    return TabBarView(
      controller: _tabCtrl,
      children: _tabs.map((t) => _ResultsTab(query: _query, type: t)).toList(),
    );
  }

  List<Widget> get _categoryCards => [
    _CatCard(emoji: '💻', label: 'Web Dev', color: const Color(0xFFEEF2FF)),
    _CatCard(emoji: '🏥', label: 'Medicine', color: const Color(0xFFF0FDF4)),
    _CatCard(emoji: '🎨', label: 'Design', color: const Color(0xFFFFF0F8)),
    _CatCard(emoji: '💰', label: 'Finance', color: const Color(0xFFFFFBEB)),
    _CatCard(emoji: '⚖️', label: 'Legal', color: const Color(0xFFF5F3FF)),
    _CatCard(emoji: '⚙️', label: 'Engineering', color: const Color(0xFFEFF6FF)),
  ];

  List<Map<String, String>> get _suggestedPeople => [
    {'name': 'Sarah Reynolds', 'role': 'Senior Flutter Developer', 'initials': 'SR', 'color': '6366F1'},
    {'name': 'Marco Conti', 'role': 'UI/UX Designer', 'initials': 'MC', 'color': 'EC4899'},
    {'name': 'Dr. Amira Hassan', 'role': 'Cardiologist', 'initials': 'AH', 'color': '14B8A6'},
  ];
}

class _CatCard extends StatelessWidget {
  final String emoji, label;
  final Color color;
  const _CatCard({required this.emoji, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    ]),
  );
}

class _PersonTile extends StatelessWidget {
  final String name, role, initials, color;
  const _PersonTile({required this.name, required this.role, required this.initials, required this.color});
  @override
  Widget build(BuildContext context) {
    final c = Color(int.parse('FF$color', radix: 16));
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        AvatarWidget(initials: initials, size: 44, backgroundColor: c),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(role, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ])),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            side: const BorderSide(color: AppTheme.primary),
            minimumSize: const Size(72, 32),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Follow', style: TextStyle(fontSize: 12)),
        ),
      ]),
    );
  }
}

class _ResultsTab extends StatelessWidget {
  final String query, type;
  const _ResultsTab({required this.query, required this.type});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.search, size: 52, color: AppTheme.textSecondary),
      const SizedBox(height: 16),
      Text('Searching "$query"', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Results for $type will appear here', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    ]),
  );
}