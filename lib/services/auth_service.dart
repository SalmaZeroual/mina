import 'api_service.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    // return await ApiService.post('/auth/login', {'email': email, 'password': password});
    // Mock response:
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.isNotEmpty) {
      return {'token': 'mock_token_123', 'user': {}};
    }
    throw ApiException('Invalid credentials', 401);
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    // return await ApiService.post('/auth/register', {'full_name': fullName, 'email': email, 'password': password});
    await Future.delayed(const Duration(seconds: 1));
    return {'token': 'mock_token_123', 'user': {}};
  }

  Future<void> selectCell(String cellId) async {
    // await ApiService.post('/auth/select-cell', {'cell_id': cellId});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> logout() async {
    ApiService.clearToken();
  }

  Future<void> forgotPassword(String email) async {
    // await ApiService.post('/auth/forgot-password', {'email': email});
    await Future.delayed(const Duration(seconds: 1));
  }
}
