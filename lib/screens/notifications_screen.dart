import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/notifications_provider.dart';
import '../models/notification_model.dart';
import '../widgets/common/loading_widget.dart';
import '../config/routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final np = context.read<NotificationsProvider>();
      np.load();
      // Auto-mark as read after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) np.markAllRead();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(width: 8),
          Consumer<NotificationsProvider>(builder: (_, np, __) =>
            np.unreadCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                    child: Text('${np.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  )
                : const SizedBox.shrink(),
          ),
        ]),
        actions: [
          Consumer<NotificationsProvider>(
            builder: (_, np, __) => np.unreadCount > 0
                ? TextButton(
                    onPressed: np.markAllRead,
                    child: const Text('Mark all read', style: TextStyle(color: AppTheme.primary, fontSize: 13)),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (_, np, __) {
          if (np.isLoading && np.notifications.isEmpty) return const LoadingWidget();
          if (np.notifications.isEmpty) return _EmptyNotifs();

          // Group by Today / Earlier
          final today = <NotificationModel>[];
          final earlier = <NotificationModel>[];
          final now = DateTime.now();
          for (final n in np.notifications) {
            if (now.difference(n.createdAt).inHours < 24) today.add(n); else earlier.add(n);
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: np.load,
            child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
              if (today.isNotEmpty) ...[
                _SectionLabel(label: 'Today'),
                ...today.map((n) => _NotifTile(notif: n)),
              ],
              if (earlier.isNotEmpty) ...[
                _SectionLabel(label: 'Earlier'),
                ...earlier.map((n) => _NotifTile(notif: n)),
              ],
            ]),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
  );
}

class _EmptyNotifs extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.06), shape: BoxShape.circle),
        child: const Icon(Icons.notifications_none_outlined, size: 38, color: AppTheme.primary),
      ),
      const SizedBox(height: 20),
      const Text("You're all caught up!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(height: 8),
      const Text(
        'When you receive likes, comments,\nor join requests, they\'ll appear here.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
      ),
    ]),
  );
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : AppTheme.primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead ? Colors.transparent : AppTheme.primary.withOpacity(0.15),
          ),
          boxShadow: notif.isRead
              ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))]
              : [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Icon circle
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: _bgColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(child: Text(_icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(notif.title, style: TextStyle(
                  fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                  fontSize: 14, color: const Color(0xFF1A1A2E),
                )),
              ),
              if (!notif.isRead)
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
            ]),
            if (notif.body != null && notif.body!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(notif.body!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
            ],
            const SizedBox(height: 6),
            Text(notif.timeAgo, style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 11)),
          ])),
          // Action button for join requests
          if (notif.type == 'join_request') ...[
            const SizedBox(width: 8),
            Column(children: [
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  String get _icon => switch (notif.type) {
    'join_request'       => '📬',
    'new_member'         => '🎉',
    'request_approved'   => '✅',
    'request_rejected'   => '❌',
    'like'               => '❤️',
    'comment'            => '💬',
    'follow'             => '👥',
    'service_inquiry'    => '💼',
    _                    => '🔔',
  };

  Color get _bgColor => switch (notif.type) {
    'join_request'       => Colors.orange,
    'new_member'         => AppTheme.success,
    'request_approved'   => AppTheme.success,
    'request_rejected'   => Colors.red,
    'like'               => AppTheme.primary,
    'comment'            => const Color(0xFF6366F1),
    'follow'             => const Color(0xFF8B5CF6),
    _                    => AppTheme.primary,
  };

  void _onTap(BuildContext context) {
    if (notif.data != null) {
      if (notif.data!['group_id'] != null) {
        Navigator.pushNamed(context, AppRoutes.groupDetail, arguments: notif.data!['group_id'] as String);
      }
    }
  }
}