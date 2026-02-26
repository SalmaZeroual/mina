import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/messages_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../config/routes.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<MessagesProvider>().loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Consumer<MessagesProvider>(
        builder: (_, mp, __) {
          if (mp.isLoading) return const LoadingWidget();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SearchBarWidget(hint: 'Search conversations...', onChanged: (_) {}),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: mp.conversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
                  itemBuilder: (_, i) {
                    final conv = mp.conversations[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Stack(
                        children: [
                          AvatarWidget(initials: conv.participant.initials),
                          if (conv.participant.isOnline)
                            Positioned(
                              right: 0, bottom: 0,
                              child: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(color: AppTheme.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(conv.participant.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text(conv.timeAgo, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(conv.participant.title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(conv.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
                              if (conv.unreadCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                                  child: Text('${conv.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.chat, arguments: conv),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
