import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _service.getNotifications();
      _notifications = result['notifications'];
      _unreadCount = result['unread_count'];
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAllRead() async {
    try {
      await _service.markAllRead();
      _unreadCount = 0;
      _notifications = _notifications.map((n) => NotificationModel.fromJson({
        'id': n.id, 'type': n.type, 'title': n.title, 'body': n.body,
        'data': n.data, 'is_read': true, 'created_at': n.createdAt.toIso8601String(),
      })).toList();
      notifyListeners();
    } catch (_) {}
  }
}