import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/service_model.dart';

class MarketplaceRemoteDataSource {
  final ApiClient _client;
  const MarketplaceRemoteDataSource(this._client);

  Future<List<ServiceModel>> getServices({String scope = 'cell', int page = 1}) async {
    try {
      final res = await _client.get(
        ApiEndpoints.services,
        queryParameters: {'scope': scope, 'page': page},
      );
      return (res.data['data'] as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<List<ServiceModel>> getMyServices() async {
    try {
      final res = await _client.get(ApiEndpoints.myServices);
      return (res.data['data'] as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<ServiceModel> createService({
    required String title,
    required String description,
    required int priceDa,
    required String unit,
  }) async {
    try {
      final res = await _client.post(ApiEndpoints.createService, data: {
        'title':       title,
        'description': description,
        'price_da':    priceDa,
        'unit':        unit,
      });
      return ServiceModel.fromJson(res.data['data']);
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<ServiceModel> updateService({
    required String serviceId,
    String? title,
    String? description,
    int? priceDa,
    String? unit,
    bool? isActive,
  }) async {
    try {
      final res = await _client.put(
        ApiEndpoints.serviceDetail(serviceId),
        data: {
          if (title != null)       'title':       title,
          if (description != null) 'description': description,
          if (priceDa != null)     'price_da':    priceDa,
          if (unit != null)        'unit':        unit,
          if (isActive != null)    'is_active':   isActive,
        },
      );
      return ServiceModel.fromJson(res.data['data']);
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _client.delete(ApiEndpoints.deleteService(serviceId));
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  String _parse(dynamic e) {
    try {
      return (e as dynamic).response?.data['error'] ?? 'Erreur réseau';
    } catch (_) {
      return 'Erreur réseau';
    }
  }
}