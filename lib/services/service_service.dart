import 'api_service.dart';
import '../models/service_model.dart';

class ServiceService {
  Future<List<ServiceModel>> getServices({String? q}) async {
    final query = q != null ? '?q=$q' : '';
    final data = await ApiService.get('/services$query');
    return (data['data'] as List).map((j) => ServiceModel.fromJson(j)).toList();
  }

  Future<ServiceModel> createService(Map<String, dynamic> body) async {
    final data = await ApiService.post('/services', body);
    return ServiceModel.fromJson(data['data']);
  }

  Future<List<ServiceModel>> getMyServices() async {
    final data = await ApiService.get('/services/mine');
    return (data['data'] as List).map((j) => ServiceModel.fromJson(j)).toList();
  }
}