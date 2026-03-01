import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

enum FeedFilter { all, posts, people, groups, services }

class HomeProvider extends ChangeNotifier {
  final PostService _service = PostService();
  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isPosting = false;
  String? _error;
  FeedFilter _filter = FeedFilter.all;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isPosting => _isPosting;
  String? get error => _error;
  FeedFilter get filter => _filter;

  void setFilter(FeedFilter f) {
    _filter = f;
    notifyListeners();
    loadPosts();
  }

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

  Future<bool> createPost(String content) async {
    if (content.trim().isEmpty) return false;
    _isPosting = true;
    _error = null;
    notifyListeners();
    try {
      final newPost = await _service.createPost(content.trim());
      // Optimistically insert at top instead of full reload
      _posts.insert(0, newPost);
      _isPosting = false;
      notifyListeners();
      // Then reload to get accurate counts
      loadPosts();
      return true;
    } catch (e) {
      _error = e.toString();
      _isPosting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleLike(String postId) async {
    // Optimistic update
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = _posts[idx];
    _posts[idx] = PostModel(
      id: post.id, author: post.author, content: post.content,
      images: post.images, createdAt: post.createdAt,
      likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      commentsCount: post.commentsCount,
      isLiked: !post.isLiked,
    );
    notifyListeners();
    try {
      await _service.toggleLike(postId);
    } catch (_) {
      // Revert
      _posts[idx] = post;
      notifyListeners();
    }
  }
}