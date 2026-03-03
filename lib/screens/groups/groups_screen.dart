import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/groups_provider.dart';
import '../../models/group_model.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../config/routes.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});
  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<GroupsProvider>().loadGroups());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Communities',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SearchBarWidget(
                hint: 'Search communities...',
                onChanged: context.read<GroupsProvider>().search,
              ),
            ),
            TabBar(
              controller: _tabs,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [Tab(text: 'Discover'), Tab(text: 'My Groups')],
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _CreateGroupSheet(parentContext: context),
          );
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text('New Community',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
      body: Consumer<GroupsProvider>(
        builder: (_, gp, __) {
          if (gp.isLoading) return const LoadingWidget();
          return TabBarView(
            controller: _tabs,
            children: [
              _GroupList(groups: gp.groups, showJoined: false),
              _GroupList(
                  groups: gp.groups.where((g) => g.isMember).toList(),
                  showJoined: true),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

// ── Group list ────────────────────────────────────────────────────────────────
class _GroupList extends StatelessWidget {
  final List<GroupModel> groups;
  final bool showJoined;
  const _GroupList({required this.groups, required this.showJoined});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
              showJoined ? Icons.group_outlined : Icons.explore_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
              showJoined
                  ? 'You haven\'t joined any group yet'
                  : 'No communities found',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 16)),
          if (!showJoined) ...[
            const SizedBox(height: 8),
            const Text('Tap the button below to create one!',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: groups.length,
      itemBuilder: (_, i) => _GroupCard(group: groups[i]),
    );
  }
}

// ── Group card ────────────────────────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  final GroupModel group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.groupDetail,
          arguments: group.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Bannière colorée
          Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [
                  _cellColor(group.cell).withOpacity(0.85),
                  _cellColor(group.cell)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Text(_groupEmoji(group.name),
                        style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(group.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      if (group.cell != null)
                        Text(group.cell!,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12)),
                    ]),
              ),
              if (group.isMember)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Member',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              if (group.isPending)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Pending',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.description,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, children: [
                    if (group.isFree)
                      _Chip(
                          label: 'Free',
                          color: const Color(0xFF10B981),
                          bgColor: const Color(0xFFECFDF5))
                    else
                      _Chip(
                          label: '\$${group.price!.toInt()}/month',
                          color: const Color(0xFF047857),
                          bgColor: const Color(0xFFECFDF5),
                          icon: Icons.attach_money),
                    if (group.requiresApproval)
                      _Chip(
                          label: 'Approval Required',
                          color: const Color(0xFFB45309),
                          bgColor: const Color(0xFFFEF3C7),
                          icon: Icons.lock_outline),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.people_outline,
                        size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('${_formatCount(group.membersCount)} members',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                    const Spacer(),
                    if (!group.isMember && !group.isPending)
                      _JoinButton(group: group),
                  ]),
                ]),
          ),
        ]),
      ),
    );
  }

  Color _cellColor(String? cell) {
    const colors = {
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
    return colors[cell] ?? AppTheme.primary;
  }

  String _groupEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('react') || n.contains('flutter') || n.contains('dev'))
      return '💻';
    if (n.contains('design') || n.contains('ui') || n.contains('ux'))
      return '🎨';
    if (n.contains('startup') || n.contains('business')) return '🚀';
    if (n.contains('freelance')) return '💼';
    if (n.contains('backend') || n.contains('api')) return '⚙️';
    if (n.contains('data') || n.contains('ai') || n.contains('ml'))
      return '🤖';
    if (n.contains('mobile')) return '📱';
    if (n.contains('health') || n.contains('medic')) return '🏥';
    if (n.contains('finance') || n.contains('invest')) return '📈';
    return '🌐';
  }

  String _formatCount(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

// ── Chip ──────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;
  const _Chip(
      {required this.label,
      required this.color,
      required this.bgColor,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4)
        ],
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ── Join button ───────────────────────────────────────────────────────────────
class _JoinButton extends StatefulWidget {
  final GroupModel group;
  const _JoinButton({required this.group});
  @override
  State<_JoinButton> createState() => _JoinButtonState();
}

class _JoinButtonState extends State<_JoinButton> {
  bool _loading = false;

  Future<void> _join() async {
    setState(() => _loading = true);
    final result =
        await context.read<GroupsProvider>().joinGroup(widget.group.id);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result != null) {
      final status = result['data']?['status'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(status == 'pending'
            ? '📬 Request sent! The admin will review it.'
            : '🎉 Welcome to ${widget.group.name}!'),
        backgroundColor:
            status == 'pending' ? Colors.orange : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _join,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(20)),
        child: _loading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(
                widget.group.requiresApproval ? 'Request' : 'Join',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Create group sheet ────────────────────────────────────────────────────────
class _CreateGroupSheet extends StatefulWidget {
  final BuildContext parentContext;
  const _CreateGroupSheet({required this.parentContext});
  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _requiresApproval = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    final group = await context.read<GroupsProvider>().createGroup(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          requiresApproval: _requiresApproval,
        );

    if (!mounted) return;

    // Ferme le sheet en premier
    Navigator.pop(context);

    if (group != null) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text('🎉 "${group.name}" created!'),
        ]),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
      Navigator.pushNamed(widget.parentContext, AppRoutes.groupDetail,
          arguments: group.id);
    } else {
      final err = context.read<GroupsProvider>().error;
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(SnackBar(
        content: Text(err ?? 'Failed to create group'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Create Community',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                  'Build a space for professionals in your field',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Community Name *',
                    hintText: 'e.g. React Native Masters'),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Name must be at least 2 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this community about?',
                    alignLabelWithHint: true),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: SwitchListTile(
                  value: _requiresApproval,
                  onChanged: (v) =>
                      setState(() => _requiresApproval = v),
                  activeColor: AppTheme.primary,
                  title: const Text('Members need approval',
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: const Text('You review each join request',
                      style: TextStyle(fontSize: 12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<GroupsProvider>(
                builder: (_, gp, __) => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: gp.isCreating ? null : _create,
                    child: gp.isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Create Community',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}