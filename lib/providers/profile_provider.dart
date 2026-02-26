import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../services/user_service.dart';
import '../services/post_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserModel? _user;
  List<PostModel> _userPosts = [];
  bool _isLoading = false;

  UserModel? get user => _user;
  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await UserService().getProfile(userId);
      _userPosts = await PostService().getUserPosts(userId);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await UserService().updateProfile(data);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}