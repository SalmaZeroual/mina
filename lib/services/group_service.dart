import 'api_service.dart';
import '../models/group_model.dart';

class GroupService {
  // ── Groups ──────────────────────────────────────────────────────────────────
  Future<List<GroupModel>> getGroups({String? q, String? cellId}) async {
    String path = '/groups';
    final params = <String>[];
    if (q != null && q.isNotEmpty) params.add('q=${Uri.encodeComponent(q)}');
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
    double price = 0,
    bool showMembersCount = true,
  }) async {
    final data = await ApiService.post('/groups', {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
      'requires_approval': requiresApproval,
      'is_free': isFree,
      if (!isFree) 'price': price,
      'show_members_count': showMembersCount,
    });
    return GroupModel.fromJson(data['data']);
  }

  Future<GroupModel> updateGroup(String groupId, Map<String, dynamic> fields) async {
    final data = await ApiService.put('/groups/$groupId', fields);
    return GroupModel.fromJson(data['data']);
  }

  Future<void> deleteGroup(String groupId) async {
    await ApiService.delete('/groups/$groupId');
  }

  // ── Join / Leave ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> joinGroup(String groupId) async {
    final data = await ApiService.post('/groups/$groupId/join', {});
    return data;
  }

  Future<void> leaveGroup(String groupId) async {
    await ApiService.delete('/groups/$groupId/leave');
  }

  // ── Members ─────────────────────────────────────────────────────────────────
  Future<List<GroupMemberModel>> getMembers(String groupId) async {
    final data = await ApiService.get('/groups/$groupId/members');
    return (data['data'] as List).map((m) => GroupMemberModel.fromJson(m)).toList();
  }

  Future<void> promoteToAdmin(String groupId, String userId) async {
    await ApiService.post('/groups/$groupId/members/$userId/promote', {});
  }

  Future<void> demoteAdmin(String groupId, String userId) async {
    await ApiService.post('/groups/$groupId/members/$userId/demote', {});
  }

  Future<void> removeMember(String groupId, String userId) async {
    await ApiService.delete('/groups/$groupId/members/$userId');
  }

  // ── Join Requests ───────────────────────────────────────────────────────────
  Future<List<JoinRequestModel>> getJoinRequests(String groupId) async {
    final data = await ApiService.get('/groups/$groupId/requests');
    return (data['data'] as List).map((r) => JoinRequestModel.fromJson(r)).toList();
  }

  Future<void> handleRequest(String groupId, String requestId, String action) async {
    await ApiService.put('/groups/$groupId/requests/$requestId', {'action': action});
  }

  // ── Posts ───────────────────────────────────────────────────────────────────
  Future<List<GroupPostModel>> getPosts(String groupId, {int page = 1}) async {
    final data = await ApiService.get('/groups/$groupId/posts?page=$page&limit=30');
    return (data['data'] as List).map((p) => GroupPostModel.fromJson(p)).toList();
  }

  Future<GroupPostModel> createPost(String groupId, String content) async {
    final data = await ApiService.post('/groups/$groupId/posts', {'content': content});
    return GroupPostModel.fromJson(data['data']);
  }

  Future<void> deletePost(String groupId, String postId) async {
    await ApiService.delete('/groups/$groupId/posts/$postId');
  }

  Future<bool> togglePinPost(String groupId, String postId) async {
    final data = await ApiService.post('/groups/$groupId/posts/$postId/pin', {});
    return data['data']['is_pinned'] as bool? ?? false;
  }

  Future<bool> likePost(String postId) async {
    final data = await ApiService.post('/posts/$postId/like', {});
    // uses group post like endpoint
    return data['data']['liked'] as bool? ?? false;
  }

  Future<bool> likeGroupPost(String postId) async {
    final data = await ApiService.post('/groups/posts/$postId/like', {});
    return data['data']['liked'] as bool? ?? false;
  }

  // ── Comments ─────────────────────────────────────────────────────────────────
  Future<List<GroupCommentModel>> getComments(String groupId, String postId) async {
    final data = await ApiService.get('/groups/$groupId/posts/$postId/comments');
    return (data['data'] as List).map((c) => GroupCommentModel.fromJson(c)).toList();
  }

  Future<GroupCommentModel> addComment(String groupId, String postId, String content) async {
    final data = await ApiService.post('/groups/$groupId/posts/$postId/comments', {'content': content});
    return GroupCommentModel.fromJson(data['data']);
  }
}