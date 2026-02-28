import 'api_service.dart';
import '../models/group_model.dart';

class GroupService {
  Future<List<GroupModel>> getGroups({String? q, String? cellId}) async {
    String path = '/groups';
    final params = <String>[];
    if (q != null && q.isNotEmpty) params.add('q=$q');
    if (cellId != null) params.add('cell_id=$cellId');
    if (params.isNotEmpty) path += '?${params.join('&')}';
    final data = await ApiService.get(path);
    return (data['data'] as List).map((j) => GroupModel.fromJson(j)).toList();
  }

  Future<GroupModel> getGroup(String groupId) async {
    final data = await ApiService.get('/groups/$groupId');
    return GroupModel.fromJson(data['data']);
  }

  Future<GroupModel> createGroup({
    required String name,
    String? description,
    bool requiresApproval = true,
    bool isFree = true,
  }) async {
    final data = await ApiService.post('/groups', {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
      'requires_approval': requiresApproval,
      'is_free': isFree,
    });
    return GroupModel.fromJson(data['data']);
  }

  Future<Map<String, dynamic>> joinGroup(String groupId) async {
    final data = await ApiService.post('/groups/$groupId/join', {});
    return data;
  }

  Future<void> leaveGroup(String groupId) async {
    await ApiService.delete('/groups/$groupId/leave');
  }

  Future<List<GroupMemberModel>> getMembers(String groupId) async {
    final data = await ApiService.get('/groups/$groupId/members');
    return (data['data'] as List).map((m) => GroupMemberModel.fromJson(m)).toList();
  }

  Future<List<JoinRequestModel>> getJoinRequests(String groupId) async {
    final data = await ApiService.get('/groups/$groupId/requests');
    return (data['data'] as List).map((r) => JoinRequestModel.fromJson(r)).toList();
  }

  Future<void> handleRequest(String groupId, String requestId, String action) async {
    await ApiService.put('/groups/$groupId/requests/$requestId', {'action': action});
  }
}