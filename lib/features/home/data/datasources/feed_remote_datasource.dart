import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/post_model.dart';

// Pas d'abstract — classe concrète directement comme AuthRemoteDataSource
class FeedRemoteDataSource {
  final ApiClient _client;
  const FeedRemoteDataSource(this._client);

  Future<List<PostModel>> getCellFeed({
    required String cellId,
    int page = 1,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.cellFeed(cellId),
        queryParameters: {'page': page},
      );
      return (response.data['data'] as List)
          .map((e) => PostModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PostModel> createPost({
    required String cellId,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.createPost,
        data: {
          'cell_id': cellId,
          'content': content,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );
      return PostModel.fromJson(response.data['data']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PostModel> toggleLike({required String postId}) async {
    try {
      final response = await _client.post(ApiEndpoints.likePost(postId));
      return PostModel.fromJson(response.data['data']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> deletePost({required String postId}) async {
    try {
      await _client.delete(ApiEndpoints.deletePost(postId));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}