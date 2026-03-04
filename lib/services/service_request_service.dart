import 'api_service.dart';
import '../models/service_request_model.dart';

class ServiceRequestService {
  Future<void> sendRequest(String serviceId, String message, {double? budget}) async {
    await ApiService.post('/services/$serviceId/requests', {
      'message': message,
      if (budget != null) 'budget': budget,
    });
  }

  Future<List<ServiceRequestModel>> getReceived({String? status}) async {
    final path = '/services/requests/received${status != null ? '?status=$status' : ''}';
    final data = await ApiService.get(path);
    return (data['data'] as List).map((j) => ServiceRequestModel.fromJson(j)).toList();
  }

  Future<List<ServiceRequestModel>> getSent({String? status}) async {
    final path = '/services/requests/sent${status != null ? '?status=$status' : ''}';
    final data = await ApiService.get(path);
    return (data['data'] as List).map((j) => ServiceRequestModel.fromJson(j)).toList();
  }

  Future<Map<String, ServiceStatsModel>> getStats() async {
    final data = await ApiService.get('/services/requests/stats');
    final d = data['data'] as Map<String, dynamic>;
    return {
      'received': ServiceStatsModel.fromJson(d['received'] as Map<String, dynamic>? ?? {}),
      'sent':     ServiceStatsModel.fromJson(d['sent']     as Map<String, dynamic>? ?? {}),
    };
  }

  Future<String> acceptRequest(String requestId) async {
    final data = await ApiService.put('/services/requests/$requestId/accept', {});
    return data['data']['conversation_id'] as String;
  }

  Future<void> declineRequest(String requestId, {String? reason}) async {
    await ApiService.put('/services/requests/$requestId/decline',
        {if (reason != null) 'reason': reason});
  }

  Future<void> completeRequest(String requestId) async {
    await ApiService.put('/services/requests/$requestId/complete', {});
  }

  Future<void> cancelRequest(String requestId) async {
    await ApiService.put('/services/requests/$requestId/cancel', {});
  }
}