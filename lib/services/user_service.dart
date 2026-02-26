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

  Future<void> follow(String userId) async {
    await ApiService.post('/users/$userId/follow', {});
  }

  Future<void> unfollow(String userId) async {
    await ApiService.delete('/users/$userId/follow');
  }
}