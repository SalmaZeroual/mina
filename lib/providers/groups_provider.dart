import 'package:flutter/material.dart';
import '../models/group_model.dart';

class GroupsProvider extends ChangeNotifier {
  List<GroupModel> _groups = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<GroupModel> get groups => _searchQuery.isEmpty
      ? _groups
      : _groups.where((g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  bool get isLoading => _isLoading;

  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _groups = GroupModel.mocks;
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> joinGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }
}
