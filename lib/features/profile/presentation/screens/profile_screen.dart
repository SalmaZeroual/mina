import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/user_avatar.dart';
import '../../../../../shared/widgets/loading_skeleton.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/edit_profile_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId; // null = mon profil
  const ProfileScreen({super.key, this.userId});
  @override ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String? _resolvedId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  String _getProfileId() {
    if (widget.userId != null) return widget.userId!;
    final auth = ref.read(authProvider);
    return auth is AuthAuthenticated ? auth.user.id : '';
  }

  @override
  Widget build(BuildContext context) {
    final profileId = widget.userId ?? _getProfileId();
    if (profileId.isEmpty) return const Scaffold(body: LoadingSkeleton());

    final state  = ref.watch(profileProvider(profileId));
    final authSt = ref.watch(authProvider);
    final isMe   = authSt is AuthAuthenticated && authSt.user.id == profileId;

    // Charger au premier build
    if (state is ProfileInitial) {
      Future.microtask(() => ref.read(profileProvider(profileId).notifier).load());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isMe ? 'Mon Profil' : 'Profil'),
        actions: isMe ? [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context, profileId, state),
          ),
        ] : null,
      ),
      body: switch (state) {
        ProfileLoading() => const LoadingSkeleton(),
        ProfileInitial() => const LoadingSkeleton(),
        ProfileError(:final message) => Center(
          child: Text(message, style: const TextStyle(color: AppColors.greyMuted))),
        ProfileLoaded(:final profile) => NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(child: _ProfileHeader(
              profile: profile, isMe: isMe,
              onEditAvatar: isMe ? () => _pickAvatar(profileId) : null,
              onFollow: !isMe ? () => ref.read(profileProvider(profileId).notifier).toggleFollow() : null,
              onEdit: isMe ? () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
                builder: (_) => EditProfileSheet(
                  userId: profileId,
                  currentName: profile.name,
                  currentBio: profile.bio,
                ),
              ) : null,
            )),
            SliverPersistentHeader(
              delegate: _TabsDelegate(_tabs), pinned: true),
          ],
          body: TabBarView(
            controller: _tabs,
            children: [
              _PostsTab(userId: profile.id),
              _FollowTab(label: 'Abonnés',    count: profile.followersCount),
              _FollowTab(label: 'Abonnements', count: profile.followingCount),
            ],
          ),
        ),
        _ => const SizedBox(),
      },
    );
  }

  Future<void> _pickAvatar(String profileId) async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) {
      await ref.read(profileProvider(profileId).notifier).updateAvatar(img.path);
    }
  }

  void _showSettings(BuildContext context, String profileId, ProfileState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 36, height: 3,
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
        _SettingsItem(icon: Icons.lock_outline, label: 'Confidentialité', onTap: () {}),
        _SettingsItem(
          icon: Icons.edit_outlined, label: 'Modifier mes infos',
          onTap: () {
            Navigator.pop(context);
            if (state is ProfileLoaded) {
              showModalBottomSheet(
                context: context, isScrollControlled: true,
                backgroundColor: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
                builder: (_) => EditProfileSheet(
                  userId: profileId,
                  currentName: state.profile.name,
                  currentBio: state.profile.bio,
                ),
              );
            }
          },
        ),
        const Divider(),
        ListTile(
          leading: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(.1),
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.logout, color: AppColors.error, size: 18)),
          title: Text('Se déconnecter',
            style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.error)),
          onTap: () {
            Navigator.pop(context);
            ref.read(authProvider.notifier).signOut();
          },
        ),
        const SizedBox(height: 8),
      ])),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final dynamic profile;
  final bool isMe;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onFollow;
  final VoidCallback? onEdit;
  const _ProfileHeader({required this.profile, required this.isMe,
    this.onEditAvatar, this.onFollow, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Avatar
        GestureDetector(
          onTap: onEditAvatar,
          child: Stack(alignment: Alignment.bottomRight, children: [
            UserAvatar(name: profile.name, avatarUrl: profile.avatarUrl, size: 80),
            if (isMe)
              Container(width: 24, height: 24,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 12, color: AppColors.white)),
          ]),
        ),
        const SizedBox(height: 12),

        // Nom
        Text(profile.name,
          style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.white)),
        const SizedBox(height: 8),

        // Cell chip — non modifiable
        _CellChip(cell: profile.cell),
        const SizedBox(height: 8),

        // Bio
        if (profile.bio != null && profile.bio!.isNotEmpty)
          Text(profile.bio!, textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.greyMuted, fontSize: 13, height: 1.5)),

        const SizedBox(height: 14),

        // Stats
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Stat('${profile.followersCount}', 'Abonnés'),
          Container(width: 1, height: 28, color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 20)),
          _Stat('${profile.followingCount}', 'Abonnements'),
          Container(width: 1, height: 28, color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 20)),
          _Stat('${profile.postsCount}', 'Posts'),
        ]),

        const SizedBox(height: 14),

        // Actions
        Row(children: [
          if (isMe)
            Expanded(child: ElevatedButton(
              onPressed: onEdit,
              child: const Text('Modifier profil')))
          else
            Expanded(child: ElevatedButton(
              onPressed: onFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: profile.isFollowedByMe ? AppColors.surface2 : AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: Text(profile.isFollowedByMe ? 'Abonné ✓' : 'Suivre'))),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () {},
            child: const Icon(Icons.share_outlined, size: 18)),
        ]),
      ]),
    );
  }
}

class _CellChip extends StatelessWidget {
  final dynamic cell;
  const _CellChip({required this.cell});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: cell.color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cell.color.withOpacity(.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(
          shape: BoxShape.circle, color: cell.color,
          boxShadow: [BoxShadow(color: cell.color, blurRadius: 5)],
        )),
        const SizedBox(width: 7),
        Text('${cell.emoji}  ${cell.label.toUpperCase()}',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.w800, fontSize: 11,
            color: cell.color, letterSpacing: .06)),
        const SizedBox(width: 6),
        Icon(Icons.lock_outline, size: 11, color: cell.color.withOpacity(.6)),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String number, label;
  const _Stat(this.number, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(number, style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.white)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.greyMuted)),
  ]);
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabs;
  const _TabsDelegate(this.tabs);
  @override double get minExtent => 46;
  @override double get maxExtent => 46;
  @override bool shouldRebuild(_) => false;
  @override
  Widget build(_, __, ___) => Container(
    color: AppColors.black,
    child: TabBar(
      controller: tabs,
      indicatorColor: AppColors.primary,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.greyMuted,
      labelStyle: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 11),
      tabs: const [
        Tab(text: 'PUBLICATIONS'),
        Tab(text: 'ABONNÉS'),
        Tab(text: 'ABONNEMENTS'),
      ],
    ),
  );
}

class _PostsTab extends StatelessWidget {
  final String userId;
  const _PostsTab({required this.userId});
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('Publications à venir...', style: TextStyle(color: AppColors.greyMuted)));
}

class _FollowTab extends StatelessWidget {
  final String label;
  final int count;
  const _FollowTab({required this.label, required this.count});
  @override
  Widget build(BuildContext context) => Center(
    child: Text('$count $label', style: const TextStyle(color: AppColors.greyMuted)));
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Container(width: 34, height: 34,
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: AppColors.greyMuted, size: 18)),
    title: Text(label, style: GoogleFonts.syne(
      fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.white)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.greyMuted),
  );
}