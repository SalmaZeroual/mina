import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/constants/cells_config.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _client;
  const AuthRemoteDataSource(this._client);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required MinaCell cell,
  }) async {
    try {
      await _client.post(ApiEndpoints.register, data: {
        'name': name, 'email': email,
        'password': password, 'cell_id': cell.id,
      });
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final res = await _client.post(ApiEndpoints.verifyEmail,
        data: {'email': email, 'code': code});
      return res.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  Future<void> resendCode({required String email}) async {
    try {
      await _client.post(ApiEndpoints.resendCode, data: {'email': email});
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.post(ApiEndpoints.login,
        data: {'email': email, 'password': password});
      return res.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final res = await _client.get(ApiEndpoints.me);
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  String _parseError(dynamic e) {
    try {
      return (e as dynamic).response?.data['error'] ?? 'Erreur réseau';
    } catch (_) {
      return 'Erreur réseau';
    }
  }
}