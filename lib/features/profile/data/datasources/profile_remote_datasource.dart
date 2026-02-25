import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  final ApiClient _client;
  const ProfileRemoteDataSource(this._client);

  Future<ProfileModel> getProfile(String userId) async {
    try {
      final res = await _client.get(ApiEndpoints.userProfile(userId));
      return ProfileModel.fromJson(res.data['data']);
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<ProfileModel> updateProfile({String? name, String? bio}) async {
    try {
      final res = await _client.put(ApiEndpoints.updateProfile, data: {
        if (name != null) 'name': name,
        if (bio  != null) 'bio':  bio,
      });
      return ProfileModel.fromJson(res.data['data']);
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<ProfileModel> updateAvatar(String filePath) async {
    try {
      final res = await _client.postMultipart(
        ApiEndpoints.updateAvatar,
        filePath: filePath,
        fileField: 'avatar',
      );
      return ProfileModel.fromJson(res.data['data']);
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<void> follow(String userId) async {
    try {
      await _client.post(ApiEndpoints.followUser(userId));
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<void> unfollow(String userId) async {
    try {
      await _client.delete(ApiEndpoints.unfollowUser(userId));
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