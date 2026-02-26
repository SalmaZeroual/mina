import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';

class ServicesProvider extends ChangeNotifier {
  final ServiceService _service = ServiceService();
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
    try {
      _services = await _service.getServices();
    } catch (_) {
      _services = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> publishService(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createService(data);
      await loadServices();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}