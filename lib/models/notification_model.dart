import 'dart:convert';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String? body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id, required this.type, required this.title,
    this.body, this.data, required this.isRead, required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
    id: j['id'], type: j['type'], title: j['title'], body: j['body'],
    data: j['data'] != null ? (j['data'] is String ? jsonDecode(j['data']) : j['data']) : null,
    isRead: j['is_read'] == 1 || j['is_read'] == true,
    createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
  );

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}