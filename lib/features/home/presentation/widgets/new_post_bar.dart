import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../../../shared/widgets/user_avatar.dart';
import '../providers/feed_provider.dart';

class NewPostBar extends ConsumerWidget {
  const NewPostBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;

    return GestureDetector(
      onTap: () => _showSheet(context, ref),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          UserAvatar(name: user?.name ?? '', avatarUrl: user?.avatarUrl, size: 34),
          const SizedBox(width: 12),
          Text('Partage quelque chose avec ta cellule...',
            style: const TextStyle(color: AppColors.greyLight, fontSize: 13)),
        ]),
      ),
    );
  }

  void _showSheet(BuildContext ctx, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 3, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Nouveau post', style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.white)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl, maxLines: 4, autofocus: true,
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(hintText: 'Quoi de neuf dans ta cellule ?'),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(feedProvider.notifier).createPost(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Publier'),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
