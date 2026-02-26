import 'package:flutter/material.dart';
import '../models/service_model.dart';

class ServicesProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<ServiceModel> get services => _searchQuery.isEmpty
      ? _services
      : _services.where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  bool get isLoading => _isLoading;

  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _services = ServiceModel.mocks;
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> publishService(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }
}
