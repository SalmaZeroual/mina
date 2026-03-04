import 'api_service.dart';
import '../models/service_model.dart';

class ServiceService {
  Future<List<ServiceModel>> getServices({String? q, String? cellId}) async {
    String path = '/services';
    final params = <String>[];
    if (q != null && q.isNotEmpty) params.add('q=${Uri.encodeComponent(q)}');
    if (cellId != null) params.add('cell_id=$cellId');
    if (params.isNotEmpty) path += '?${params.join('&')}';
    final data = await ApiService.get(path);
    return (data['data'] as List).map((j) => ServiceModel.fromJson(j)).toList();
  }

  Future<List<ServiceModel>> getMyServices() async {
    final data = await ApiService.get('/services/mine');
    return (data['data'] as List).map((j) => ServiceModel.fromJson(j)).toList();
  }

  Future<ServiceModel> createService(Map<String, dynamic> body) async {
    final data = await ApiService.post('/services', body);
    return ServiceModel.fromJson(data['data']);
  }

  Future<ServiceModel> updateService(String serviceId, Map<String, dynamic> body) async {
    final data = await ApiService.put('/services/$serviceId', body);
    return ServiceModel.fromJson(data['data']);
  }

  Future<void> deleteService(String serviceId) async {
    await ApiService.delete('/services/$serviceId');
  }

  Future<List<ServiceReviewModel>> getReviews(String serviceId) async {
    final data = await ApiService.get('/services/$serviceId/reviews');
    return (data['data'] as List).map((j) => ServiceReviewModel.fromJson(j)).toList();
  }

  Future<void> addReview(String serviceId, int rating, String? comment) async {
    await ApiService.post('/services/$serviceId/reviews', {
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
  }
}