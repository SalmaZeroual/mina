import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/entities/group_entity.dart';
import '../providers/groups_provider.dart';

class GroupCard extends ConsumerWidget {
  final GroupEntity group;
  final bool isMine;
  const GroupCard({super.key, required this.group, this.isMine = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: group.cell.color.withOpacity(.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(group.cell.emoji, style: const TextStyle(fontSize: 20))),
        ),
        title: Text(group.name,
          style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.white)),
        subtitle: Text('${group.membersCount} membres · ${group.creatorName}',
          style: const TextStyle(fontSize: 11, color: AppColors.greyMuted)),
        trailing: isMine
          ? _RoleBadge(role: group.myRole ?? 'member')
          : _JoinButton(group: group),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});
  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: (isAdmin ? AppColors.primary : AppColors.greyLight).withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isAdmin ? AppColors.primary : AppColors.greyLight).withOpacity(.3)),
      ),
      child: Text(isAdmin ? 'Admin' : 'Membre',
        style: GoogleFonts.syne(fontSize: 10, fontWeight: FontWeight.w700,
          color: isAdmin ? AppColors.primary : AppColors.greyLight)),
    );
  }
}

class _JoinButton extends ConsumerWidget {
  final GroupEntity group;
  const _JoinButton({required this.group});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (group.isMember) {
      return TextButton(
        onPressed: () => ref.read(groupsProvider.notifier).leave(group.id),
        style: TextButton.styleFrom(foregroundColor: AppColors.greyMuted),
        child: const Text('Quitter', style: TextStyle(fontSize: 11)),
      );
    }
    return ElevatedButton(
      onPressed: () => ref.read(groupsProvider.notifier).join(group.id),
      style: ElevatedButton.styleFrom(minimumSize: const Size(80, 32), padding: const EdgeInsets.symmetric(horizontal: 12)),
      child: Text(group.isPremium ? '${group.priceDa} DA' : 'Rejoindre',
        style: const TextStyle(fontSize: 11)),
    );
  }
}