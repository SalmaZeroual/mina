import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/group_model.dart';

class GroupRemoteDataSource {
  final ApiClient _client;
  const GroupRemoteDataSource(this._client);

  Future<List<GroupModel>> discoverGroups({int page = 1}) async {
    try {
      final res = await _client.get(
        ApiEndpoints.discoverGroups,
        queryParameters: {'page': page},
      );
      return (res.data['data'] as List)
          .map((e) => GroupModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<List<GroupModel>> getMyGroups() async {
    try {
      final res = await _client.get(ApiEndpoints.myGroups);
      return (res.data['data'] as List)
          .map((e) => GroupModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<GroupModel> getGroupById(String groupId) async {
    try {
      final res = await _client.get(ApiEndpoints.groupDetail(groupId));
      return GroupModel.fromJson(res.data['data']);
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<GroupModel> createGroup({
    required String name,
    String? description,
    bool isPremium = false,
    int priceDa = 0,
  }) async {
    try {
      final res = await _client.post(ApiEndpoints.createGroup, data: {
        'name': name,
        if (description != null) 'description': description,
        'is_premium': isPremium,
        'price_da': priceDa,
      });
      return GroupModel.fromJson(res.data['data']);
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<void> join(String groupId) async {
    try {
      await _client.post(ApiEndpoints.joinGroup(groupId));
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<void> leave(String groupId) async {
    try {
      await _client.delete(ApiEndpoints.leaveGroup(groupId));
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