import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class HomeProvider extends ChangeNotifier {
  final PostService _service = PostService();
  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isPosting = false;
  String? _error;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isPosting => _isPosting;
  String? get error => _error;

  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _posts = await _service.getFeed();
    } catch (e) {
      _error = e.toString();
      _posts = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPost(String content) async {
    _isPosting = true;
    notifyListeners();
    try {
      await _service.createPost(content);
      await loadPosts();
    } catch (e) {
      _error = e.toString();
    }
    _isPosting = false;
    notifyListeners();
  }

  Future<void> toggleLike(String postId) async {
    try {
      await _service.toggleLike(postId);
      await loadPosts();
    } catch (_) {}
  }
}