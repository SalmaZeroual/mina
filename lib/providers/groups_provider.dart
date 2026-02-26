import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupsProvider extends ChangeNotifier {
  final GroupService _service = GroupService();
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
    try {
      _groups = await _service.getGroups();
    } catch (_) {
      _groups = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> joinGroup(String groupId) async {
    try {
      await _service.joinGroup(groupId);
      await loadGroups();
    } catch (_) {}
  }
}