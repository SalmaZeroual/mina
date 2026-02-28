import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../models/service_model.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../config/routes.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  final _categories = ['All', 'Design', 'Dev', 'Marketing', 'Finance', 'Legal', 'Medicine'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ServicesProvider>().loadServices());
  }

  @override
  void dispose() { _tabs.dispose(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Marketplace', style: TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 2),
                  const Text('Hire talent from your professional network',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.normal)),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppTheme.textPrimary),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _SearchBar(
                  controller: _searchCtrl,
                  onChanged: context.read<ServicesProvider>().search,
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryHeaderDelegate(
              categories: _categories,
              selected: _selectedCategory,
              onSelect: (c) => setState(() => _selectedCategory = c),
            ),
          ),
        ],
        body: Consumer<ServicesProvider>(
          builder: (_, sp, __) {
            if (sp.isLoading) return const LoadingWidget();
            final all = sp.services;
            final filtered = _selectedCategory == 'All'
                ? all
                : all.where((s) => (s.cell ?? '').toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

            if (filtered.isEmpty) return _EmptyState(query: _searchCtrl.text);

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _ServiceCard(service: filtered[i]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.publishService),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        label: const Text('Offer a Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search services or skills...',
          hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          prefixIcon: Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  const _CategoryHeaderDelegate({required this.categories, required this.selected, required this.onSelect});

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final isSelected = categories[i] == selected;
          return GestureDetector(
            onTap: () => onSelect(categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : const Color(0xFFF0F1F5),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[i],
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryHeaderDelegate old) => old.selected != selected;
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const _ServiceCard({required this.service});

  Color get _cellColor {
    const map = {
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
      'Real Estate': Color(0xFF84CC16),
      'Fitness & Sports': Color(0xFF06B6D4),
    };
    return map[service.cell] ?? AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.serviceDetail, arguments: service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top accent bar
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: _cellColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cell badge
                      if (service.cell != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _cellColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(service.cell!, style: TextStyle(fontSize: 11, color: _cellColor, fontWeight: FontWeight.w600)),
                        ),
                      const Spacer(),
                      // Price tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Text(
                          'From \$${service.price.toInt()}',
                          style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(service.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.3)),
                  const SizedBox(height: 6),
                  Text(service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AvatarWidget(initials: service.provider.initials, size: 32, avatarUrl: service.provider.avatarUrl),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.provider.fullName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            if (service.provider.title.isNotEmpty)
                              Text(service.provider.title,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      // Rating
                      Row(children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                        const SizedBox(width: 3),
                        Text(
                          service.rating > 0 ? service.rating.toStringAsFixed(1) : 'New',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        if (service.reviewsCount > 0) ...[
                          const SizedBox(width: 2),
                          Text('(${service.reviewsCount})',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ],
                      ]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.serviceDetail, arguments: service),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('View & Hire', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔍', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(
          query.isNotEmpty ? 'No results for "$query"' : 'No services yet',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text('Be the first to offer your expertise\nto the global community.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5)),
      ]),
    );
  }
}