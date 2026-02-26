import 'api_service.dart';
import 'storage_service.dart';
import '../models/user_model.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await ApiService.post('/auth/login', {'email': email, 'password': password});
    await StorageService.saveToken(data['data']['token']);
    await StorageService.saveUserId(data['data']['user']['id']);
    return data['data'];
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    final data = await ApiService.post('/auth/register', {'full_name': fullName, 'email': email, 'password': password});
    await StorageService.saveToken(data['data']['token']);
    await StorageService.saveUserId(data['data']['user']['id']);
    return data['data'];
  }

  Future<void> selectCell(String cellId) async {
    await ApiService.post('/auth/select-cell', {'cell_id': cellId});
  }

  Future<UserModel> getMe() async {
    final data = await ApiService.get('/auth/me');
    return UserModel.fromJson(data['data']);
  }

  Future<void> logout() async {
    try { await ApiService.post('/auth/logout', {}); } catch (_) {}
    await StorageService.clear();
  }

  Future<void> forgotPassword(String email) async {
    await ApiService.post('/auth/forgot-password', {'email': email});
  }
}