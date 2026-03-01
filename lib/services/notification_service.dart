import 'api_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  Future<Map<String, dynamic>> getNotifications() async {
    final data = await ApiService.get('/notifications?limit=50');
    return {
      'notifications': (data['data'] as List).map((j) => NotificationModel.fromJson(j)).toList(),
      'unread_count': data['unread_count'] ?? 0,
    };
  }

  Future<void> markAllRead() async {
    await ApiService.put('/notifications/read', {});
  }
}