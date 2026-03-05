import 'api_service.dart';
import '../models/user_model.dart';

class UserService {
  Future<UserModel> getProfile(String userId) async {
    final data = await ApiService.get('/users/$userId');
    return UserModel.fromJson(data['data']);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> body) async {
    final data = await ApiService.put('/users/me', body);
    return UserModel.fromJson(data['data']);
  }

  Future<List<UserModel>> searchUsers(String q) async {
    final data = await ApiService.get('/users/search?q=${Uri.encodeComponent(q)}');
    return (data['data'] as List).map((u) => UserModel.fromJson(u)).toList();
  }

  Future<void> follow(String userId) async {
    await ApiService.post('/users/$userId/follow', {});
  }

  Future<void> unfollow(String userId) async {
    await ApiService.delete('/users/$userId/follow');
  }

  Future<List<UserModel>> getFollowers(String userId) async {
    final data = await ApiService.get('/users/$userId/followers');
    return (data['data'] as List).map((u) => UserModel.fromJson(u)).toList();
  }

  Future<List<UserModel>> getFollowing(String userId) async {
    final data = await ApiService.get('/users/$userId/following');
    return (data['data'] as List).map((u) => UserModel.fromJson(u)).toList();
  }

  Future<List<dynamic>> getUserPosts(String userId) async {
    final data = await ApiService.get('/users/$userId/posts');
    return data['data'] as List;
  }

  // ── Connections ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> sendConnectionRequest(String userId) async {
    final data = await ApiService.post('/connections/request/$userId', {});
    return data['data'] as Map<String, dynamic>;
  }

  Future<void> acceptConnection(String connectionId) async {
    await ApiService.put('/connections/$connectionId/accept', {});
  }

  Future<void> declineConnection(String connectionId) async {
    await ApiService.put('/connections/$connectionId/decline', {});
  }

  Future<void> removeConnection(String userId) async {
    await ApiService.delete('/connections/remove/$userId');
  }

  Future<List<dynamic>> getPendingRequests() async {
    final data = await ApiService.get('/connections/pending');
    return data['data'] as List;
  }

  Future<List<UserModel>> getMyConnections() async {
    final data = await ApiService.get('/connections');
    return (data['data'] as List).map((u) => UserModel.fromJson(u)).toList();
  }

  Future<List<UserModel>> getUserConnections(String userId) async {
    final data = await ApiService.get('/users/$userId/connections');
    return (data['data'] as List).map((j) => UserModel.fromJson(j)).toList();
  }

  Future<bool> isNetworkHidden(String userId) async {
    final data = await ApiService.get('/users/$userId/connections');
    return data['hidden'] == true;
  }

  Future<void> blockUser(String userId) async {
    await ApiService.post('/connections/block/$userId', {});
  }

  Future<void> unblockUser(String userId) async {
    await ApiService.delete('/connections/block/$userId');
  }
}