import 'api_service.dart';
import '../models/group_model.dart';

class GroupService {
  Future<List<GroupModel>> getGroups({String? q}) async {
    final query = q != null ? '?q=$q' : '';
    final data = await ApiService.get('/groups$query');
    return (data['data'] as List).map((j) => GroupModel.fromJson(j)).toList();
  }

  Future<GroupModel> createGroup(Map<String, dynamic> body) async {
    final data = await ApiService.post('/groups', body);
    return GroupModel.fromJson(data['data']);
  }

  Future<Map<String, dynamic>> joinGroup(String groupId) async {
    final data = await ApiService.post('/groups/$groupId/join', {});
    return data['data'];
  }

  Future<void> leaveGroup(String groupId) async {
    await ApiService.delete('/groups/$groupId/leave');
  }
}