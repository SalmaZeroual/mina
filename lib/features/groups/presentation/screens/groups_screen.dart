import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/loading_skeleton.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/groups_provider.dart';
import '../providers/groups_state.dart';
import '../widgets/group_card.dart';
import '../widgets/create_group_sheet.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});
  @override ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(groupsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupsProvider);
    final auth  = ref.watch(authProvider);
    final cell  = auth is AuthAuthenticated ? auth.user.cell : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groupes'),
        actions: [
          TextButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
              builder: (_) => CreateGroupSheet(),
            ),
            icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
            label: Text('Créer', style: GoogleFonts.syne(
              color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.read(groupsProvider.notifier).load(),
        child: switch (state) {
          GroupsLoading() => const LoadingSkeleton(),
          GroupsError(:final message) => Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.wifi_off, color: AppColors.greyMuted, size: 40),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(color: AppColors.greyMuted)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(groupsProvider.notifier).load(),
                child: const Text('Réessayer'),
              ),
            ]),
          ),
          GroupsLoaded(:final myGroups, :final discover) => ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // Cellule badge
              if (cell != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cell.color.withOpacity(.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cell.color.withOpacity(.25)),
                  ),
                  child: Row(children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(
                      shape: BoxShape.circle, color: cell.color,
                      boxShadow: [BoxShadow(color: cell.color.withOpacity(.6), blurRadius: 5)],
                    )),
                    const SizedBox(width: 10),
                    Text('Groupes · Cellule ${cell.label}',
                      style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w700, color: cell.color)),
                    const Spacer(),
                    Icon(Icons.lock_outline, size: 12, color: cell.color.withOpacity(.5)),
                  ]),
                ),

              // Mes groupes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Mes Groupes', style: GoogleFonts.syne(
                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.white)),
              ),
              const SizedBox(height: 8),
              if (myGroups.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text('Tu n\'as rejoint aucun groupe.',
                    style: const TextStyle(color: AppColors.greyMuted, fontSize: 13)),
                )
              else
                ...myGroups.map((g) => GroupCard(group: g, isMine: true)),

              const SizedBox(height: 20),

              // Découvrir
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Découvrir', style: GoogleFonts.syne(
                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.white)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: discover.where((g) => !g.isMember).length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5),
                  itemBuilder: (_, i) {
                    final g = discover.where((x) => !x.isMember).toList()[i];
                    return _DiscoverCard(group: g);
                  },
                ),
              ),
            ],
          ),
          _ => const SizedBox(),
        },
      ),
    );
  }
}

class _DiscoverCard extends ConsumerWidget {
  final dynamic group;
  const _DiscoverCard({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(groupsProvider.notifier).join(group.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(group.cell.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 5),
          Text(group.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.white)),
          const SizedBox(height: 3),
          Text(group.isPremium ? '${group.priceDa} DA/mois' : 'Gratuit',
            style: GoogleFonts.syne(fontSize: 10, fontWeight: FontWeight.w700,
              color: group.isPremium ? AppColors.warning : AppColors.success)),
        ]),
      ),
    );
  }
}