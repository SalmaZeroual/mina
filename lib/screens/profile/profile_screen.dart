import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../widgets/home/post_card.dart';
import '../../config/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) context.read<ProfileProvider>().loadProfile(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (_, pp, __) {
          if (pp.isLoading || pp.user == null) {
            return const Scaffold(body: LoadingWidget(), bottomNavigationBar: BottomNavBar(currentIndex: 4));
          }
          final user = pp.user!;
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title: Text(user.fullName, style: const TextStyle(color: AppTheme.textPrimary)),
                  actions: [
                    IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AvatarWidget(initials: user.initials, size: 64),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  if (user.title.isNotEmpty)
                                    Text(user.title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                                  if (user.cell.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppTheme.border),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.lock_outline, size: 12, color: AppTheme.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(user.cell, style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          _Stat(value: '${user.postsCount}', label: 'Posts'),
                          const SizedBox(width: 24),
                          _Stat(value: _fmt(user.followersCount), label: 'Followers'),
                          const SizedBox(width: 24),
                          _Stat(value: '${user.followingCount}', label: 'Following'),
                        ]),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        _InfoRow(icon: Icons.email_outlined, text: user.email),
                        if (user.location != null) _InfoRow(icon: Icons.location_on_outlined, text: user.location!),
                        if (user.company != null) _InfoRow(icon: Icons.business_outlined, text: user.company!),
                        _InfoRow(icon: Icons.calendar_today_outlined, text: 'Joined ${_formatDate(user.joinedAt)}'),
                        if (user.about != null && user.about!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(user.about!, style: const TextStyle(color: AppTheme.textSecondary, height: 1.6, fontSize: 14)),
                        ],
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text('My Posts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => PostCard(post: pp.userPosts[i]),
                    childCount: pp.userPosts.length,
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 4),
          );
        },
      ),
    );
  }

  String _fmt(int count) => count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';
  String _formatDate(DateTime dt) {
    const m = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${m[dt.month - 1]} ${dt.year}';
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
  ]);
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, size: 16, color: AppTheme.primary),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
    ]),
  );
}