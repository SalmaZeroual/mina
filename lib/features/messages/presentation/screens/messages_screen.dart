import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/user_avatar.dart';
import '../../../../../shared/widgets/cell_tag.dart';
import '../../../../../shared/widgets/loading_skeleton.dart';
import '../providers/conversations_provider.dart';
import '../providers/messages_state.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});
  @override ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(conversationsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: Icon(Icons.search, color: AppColors.greyMuted),
            ),
          ),
        ),
        Expanded(child: switch (state) {
          ConversationsLoading() => const LoadingSkeleton(),
          ConversationsError(:final message) => Center(
            child: Text(message, style: const TextStyle(color: AppColors.greyMuted))),
          ConversationsLoaded(:final conversations) => conversations.isEmpty
            ? const Center(child: Text('Aucune conversation', style: TextStyle(color: AppColors.greyMuted)))
            : RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () => ref.read(conversationsProvider.notifier).load(),
                child: ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const Divider(indent: 76),
                  itemBuilder: (_, i) {
                    final c = conversations[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      onTap: () => context.go('/messages/${c.id}'),
                      leading: UserAvatar(name: c.otherUserName, avatarUrl: c.otherUserAvatar, size: 46),
                      title: Row(children: [
                        Text(c.otherUserName,
                          style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.white)),
                        const SizedBox(width: 6),
                        CellTag(cell: c.otherUserCell, small: true),
                      ]),
                      subtitle: Text(c.lastMessage ?? 'Nouvelle conversation',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.greyMuted)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (c.lastMessageAt != null)
                            Text(_fmt(c.lastMessageAt!),
                              style: const TextStyle(fontSize: 10, color: AppColors.greyMuted)),
                          if (c.unreadCount > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 18, height: 18, alignment: Alignment.center,
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: Text('${c.unreadCount}',
                                style: GoogleFonts.syne(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.white)),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
          _ => const SizedBox(),
        }),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.edit_outlined, color: AppColors.white),
      ),
    );
  }

  String _fmt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours   < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }
}