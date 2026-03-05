import 'api_service.dart';
import '../models/post_model.dart';

class PostService {
  Future<List<PostModel>> getFeed({int page = 1}) async {
    final data = await ApiService.get('/posts?page=$page&limit=20');
    return (data['data'] as List).map((j) => PostModel.fromJson(j)).toList();
  }

  Future<PostModel> createPost(String content) async {
    final data = await ApiService.post('/posts', {'content': content});
    return PostModel.fromJson(data['data']);
  }

  Future<Map<String, dynamic>> toggleLike(String postId) async {
    final data = await ApiService.post('/posts/$postId/like', {});
    return data['data'];
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    final data = await ApiService.get('/users/$userId/posts');
    return (data['data'] as List).map((j) => PostModel.fromJson(j)).toList();
  }

  Future<void> deletePost(String postId) async {
    await ApiService.delete('/posts/$postId');
  }

  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final data = await ApiService.get('/posts/$postId/comments');
    return List<Map<String, dynamic>>.from(data['data'] as List);
  }

  Future<Map<String, dynamic>> addComment(String postId, String content) async {
    final data = await ApiService.post('/posts/$postId/comments', {'content': content});
    return data['data'] as Map<String, dynamic>;
  }
}