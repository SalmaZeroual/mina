import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/groups_provider.dart';
import '../../models/group_model.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/search_bar_widget.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});
  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<GroupsProvider>().loadGroups());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [FloatingActionButton.small(onPressed: () {}, backgroundColor: AppTheme.primary, child: const Icon(Icons.add, color: Colors.white))],
      ),
      body: Consumer<GroupsProvider>(
        builder: (_, gp, __) {
          if (gp.isLoading) return const LoadingWidget();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text('Join communities within your cell', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchBarWidget(hint: 'Search groups...', onChanged: gp.search),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: gp.groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _GroupCard(group: gp.groups[i]),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.group_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('${group.membersCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} members', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(group.description, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              if (group.isFree)
                _Chip(label: 'Free', color: const Color(0xFF10B981), bgColor: const Color(0xFFECFDF5))
              else
                _Chip(label: '\$${group.price!.toInt()}/month', color: const Color(0xFF047857), bgColor: const Color(0xFFECFDF5), icon: Icons.attach_money),
              if (group.requiresApproval)
                _Chip(label: 'Approval Required', color: const Color(0xFFB45309), bgColor: const Color(0xFFFEF3C7), icon: Icons.lock_outline),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => context.read<GroupsProvider>().joinGroup(group.id),
              child: Text(group.requiresApproval ? 'Request to Join' : 'Join Group'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;

  const _Chip({required this.label, required this.color, required this.bgColor, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
