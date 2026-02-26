import 'package:flutter/material.dart';
import '../models/post_model.dart';

class HomeProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isPosting = false;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isPosting => _isPosting;

  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _posts = PostModel.mocks;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPost(String content) async {
    _isPosting = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isPosting = false;
    loadPosts();
  }

  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      // Toggle like state (mock)
      notifyListeners();
    }
  }
}
