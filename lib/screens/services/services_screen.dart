import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/service_model.dart';
import '../../services/service_service.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../config/routes.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  final _categories = [
    'All', 'Web Development', 'Design', 'Marketing',
    'Finance', 'Legal', 'Medicine', 'Engineering', 'Education',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().loadServices();
      context.read<ServicesProvider>().loadMyServices();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text('Marketplace',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppTheme.textPrimary)),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(_tabs.index == 0 ? 106 : 48),
              child: Column(children: [
                // Search + categories only on Discover tab
                if (_tabs.index == 0) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _SearchBar(
                      controller: _searchCtrl,
                      onChanged: context.read<ServicesProvider>().search,
                    ),
                  ),
                  SizedBox(
                    height: 46,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final sel = _categories[i] == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = _categories[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: sel ? AppTheme.primary : const Color(0xFFF0F1F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(_categories[i],
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: sel ? Colors.white : AppTheme.textSecondary)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                TabBar(
                  controller: _tabs,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Discover'),
                    Tab(text: 'My Services'),
                  ],
                ),
              ]),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            // ── Discover ───────────────────────────────────────────────────
            Consumer<ServicesProvider>(
              builder: (_, sp, __) {
                if (sp.isLoading) return const LoadingWidget();
                final filtered = _selectedCategory == 'All'
                    ? sp.services
                    : sp.services
                        .where((s) => s.cell == _selectedCategory)
                        .toList();
                if (filtered.isEmpty) {
                  return _EmptyDiscover(
                    query: _searchCtrl.text,
                    onPublish: () => Navigator.pushNamed(context, AppRoutes.publishService)
                        .then((_) => context.read<ServicesProvider>().loadServices()),
                  );
                }
                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => context.read<ServicesProvider>().loadServices(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _ServiceCard(service: filtered[i]),
                  ),
                );
              },
            ),

            // ── My Services ────────────────────────────────────────────────
            Consumer<ServicesProvider>(
              builder: (_, sp, __) {
                if (sp.isLoadingMine) return const LoadingWidget();
                if (sp.myServices.isEmpty) {
                  return _EmptyMine(
                    onPublish: () => Navigator.pushNamed(context, AppRoutes.publishService)
                        .then((_) => context.read<ServicesProvider>().loadMyServices()),
                  );
                }
                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => context.read<ServicesProvider>().loadMyServices(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: sp.myServices.length,
                    itemBuilder: (_, i) => _MyServiceCard(
                      service: sp.myServices[i],
                      onDeleted: () => context.read<ServicesProvider>().loadMyServices(),
                      onEdited: () => context.read<ServicesProvider>().loadMyServices(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.publishService).then((_) {
          context.read<ServicesProvider>().loadServices();
          context.read<ServicesProvider>().loadMyServices();
        }),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Offer a Service',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 42,
    decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(12)),
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

// ── Marketplace service card ──────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const _ServiceCard({required this.service});

  Color get _cellColor {
    const map = {
      'Web Development': Color(0xFF6366F1), 'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6),        'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6),       'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981),         'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444),       'Photography': Color(0xFFF97316),
    };
    return map[service.cell] ?? AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pushNamed(context, AppRoutes.serviceDetail, arguments: service),
    child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05), blurRadius: 12,
            offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: _cellColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (service.cell != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _cellColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(service.cell!,
                      style: TextStyle(fontSize: 11, color: _cellColor,
                          fontWeight: FontWeight.w600)),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Text('From \$${service.price.toInt()}',
                    style: const TextStyle(
                        color: Color(0xFF15803D),
                        fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 10),
            Text(service.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, height: 1.3)),
            const SizedBox(height: 6),
            Text(service.description,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(children: [
              AvatarWidget(initials: service.provider.initials, size: 32,
                  avatarUrl: service.provider.avatarUrl),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(service.provider.fullName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                if (service.provider.title.isNotEmpty)
                  Text(service.provider.title,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
              ])),
              Row(children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                const SizedBox(width: 3),
                Text(
                  service.rating > 0
                      ? service.rating.toStringAsFixed(1)
                      : 'New',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                if (service.reviewsCount > 0) ...[
                  const SizedBox(width: 2),
                  Text('(${service.reviewsCount})',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ]),
            ]),
          ]),
        ),
      ]),
    ),
  );
}

// ── My service card ───────────────────────────────────────────────────────────
class _MyServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onDeleted;
  final VoidCallback onEdited;
  const _MyServiceCard({
    required this.service,
    required this.onDeleted,
    required this.onEdited,
  });

  Color get _cellColor {
    const map = {
      'Web Development': Color(0xFF6366F1), 'Design': Color(0xFFEC4899),
      'Medicine': Color(0xFF14B8A6),        'Business': Color(0xFFF59E0B),
      'Marketing': Color(0xFF8B5CF6),       'Engineering': Color(0xFF3B82F6),
      'Finance': Color(0xFF10B981),         'Legal': Color(0xFF64748B),
      'Education': Color(0xFFEF4444),       'Photography': Color(0xFFF97316),
    };
    return map[service.cell] ?? AppTheme.primary;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Service?'),
        content: Text('Are you sure you want to delete "${service.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await ServiceService().deleteService(service.id);
      onDeleted();
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.05), blurRadius: 12,
          offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Top bar with color + status
      Container(
        height: 5,
        decoration: BoxDecoration(
          color: _cellColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Published / Draft badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: service.isPublished
                    ? AppTheme.success.withOpacity(0.12)
                    : Colors.grey.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  service.isPublished
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 11,
                  color: service.isPublished ? AppTheme.success : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  service.isPublished ? 'Published' : 'Draft',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: service.isPublished
                          ? AppTheme.success
                          : Colors.grey[600]),
                ),
              ]),
            ),
            const Spacer(),
            // Price
            Text('\$${service.price.toInt()}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primary)),
            const SizedBox(width: 12),
            // Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  size: 20, color: AppTheme.textSecondary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'edit',
                    child: Row(children: const [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ])),
                PopupMenuItem(
                    value: 'toggle',
                    child: Row(children: [
                      Icon(
                        service.isPublished
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(service.isPublished
                          ? 'Unpublish'
                          : 'Publish'),
                    ])),
                const PopupMenuDivider(),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ])),
              ],
              onSelected: (v) async {
                if (v == 'edit') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _EditServiceSheet(
                        service: service, onSaved: onEdited),
                  );
                } else if (v == 'toggle') {
                  await ServiceService().updateService(service.id,
                      {'is_published': !service.isPublished});
                  onEdited();
                } else if (v == 'delete') {
                  await _confirmDelete(context);
                }
              },
            ),
          ]),
          const SizedBox(height: 10),
          Text(service.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, height: 1.3)),
          const SizedBox(height: 6),
          Text(service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5)),
          const SizedBox(height: 12),
          // Stats row
          Row(children: [
            _Stat(icon: Icons.star_rounded,
                color: Colors.amber,
                label: service.rating > 0
                    ? service.rating.toStringAsFixed(1)
                    : 'No reviews'),
            const SizedBox(width: 16),
            _Stat(
                icon: Icons.reviews_outlined,
                color: AppTheme.textSecondary,
                label: '${service.reviewsCount} review${service.reviewsCount != 1 ? 's' : ''}'),
            if (service.cell != null) ...[
              const SizedBox(width: 16),
              _Stat(
                  icon: Icons.category_outlined,
                  color: _cellColor,
                  label: service.cell!),
            ],
          ]),
        ]),
      ),
    ]),
  );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _Stat({required this.icon, required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: color),
    const SizedBox(width: 4),
    Text(label,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
  ]);
}

// ── Edit service sheet ────────────────────────────────────────────────────────
class _EditServiceSheet extends StatefulWidget {
  final ServiceModel service;
  final VoidCallback onSaved;
  const _EditServiceSheet({required this.service, required this.onSaved});
  @override
  State<_EditServiceSheet> createState() => _EditServiceSheetState();
}

class _EditServiceSheetState extends State<_EditServiceSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.service.title);
    _descCtrl  = TextEditingController(text: widget.service.description);
    _priceCtrl = TextEditingController(text: widget.service.price.toInt().toString());
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ServiceService().updateService(widget.service.id, {
        'title':       _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price':       double.tryParse(_priceCtrl.text) ?? widget.service.price,
      });
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Service updated!'),
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
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
    child: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        )),
        const SizedBox(height: 20),
        const Text('Edit Service',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
              labelText: 'Description', alignLabelWithHint: true),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Price (\$)',
              prefixIcon: Icon(Icons.attach_money)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    ),
  );
}

// ── Empty states ──────────────────────────────────────────────────────────────
class _EmptyDiscover extends StatelessWidget {
  final String query;
  final VoidCallback onPublish;
  const _EmptyDiscover({required this.query, required this.onPublish});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔍', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          query.isNotEmpty
              ? 'No results for "$query"'
              : 'No services available yet',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Be the first to offer your expertise\nto your professional network.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onPublish,
          icon: const Icon(Icons.add),
          label: const Text('Offer a Service'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ]),
    ),
  );
}

class _EmptyMine extends StatelessWidget {
  final VoidCallback onPublish;
  const _EmptyMine({required this.onPublish});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('💼', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        const Text("You haven't published any service yet",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text(
          'Share your skills and expertise\nwith your professional network.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onPublish,
          icon: const Icon(Icons.add),
          label: const Text('Offer a Service'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ]),
    ),
  );
}