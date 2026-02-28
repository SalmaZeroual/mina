import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupsProvider extends ChangeNotifier {
  final GroupService _service = GroupService();
  List<GroupModel> _groups = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _error;
  String _searchQuery = '';

  List<GroupModel> get groups => _searchQuery.isEmpty
      ? _groups
      : _groups.where((g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get error => _error;

  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _groups = await _service.getGroups();
    } catch (e) {
      _error = e.toString();
      _groups = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<GroupModel?> createGroup({
    required String name,
    String? description,
    bool requiresApproval = true,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();
    try {
      final group = await _service.createGroup(
        name: name,
        description: description,
        requiresApproval: requiresApproval,
      );
      _groups.insert(0, group);
      _isCreating = false;
      notifyListeners();
      return group;
    } catch (e) {
      _error = e.toString();
      _isCreating = false;
      notifyListeners();
      return null;
    }
  }

  // Returns the full response data so caller can check status ('pending' vs 'active')
  Future<Map<String, dynamic>?> joinGroup(String groupId) async {
    try {
      final result = await _service.joinGroup(groupId);
      await loadGroups(); // refresh list
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      await _service.leaveGroup(groupId);
      await loadGroups();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}