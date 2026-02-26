import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

class ProfileProvider extends ChangeNotifier {
  UserModel? _user;
  List<PostModel> _userPosts = [];
  bool _isLoading = false;

  UserModel? get user => _user;
  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _user = UserModel.mock;
    _userPosts = PostModel.mocks.take(3).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }
}
