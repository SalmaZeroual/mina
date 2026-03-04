import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';

class ServicesProvider extends ChangeNotifier {
  final ServiceService _service = ServiceService();

  List<ServiceModel> _services = [];
  List<ServiceModel> _myServices = [];
  bool _isLoading = false;
  bool _isLoadingMine = false;
  String _searchQuery = '';

  List<ServiceModel> get services => _searchQuery.isEmpty
      ? _services
      : _services
          .where((s) =>
              s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  List<ServiceModel> get myServices => _myServices;
  bool get isLoading => _isLoading;
  bool get isLoadingMine => _isLoadingMine;

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

  Future<void> loadMyServices() async {
    _isLoadingMine = true;
    notifyListeners();
    try {
      _myServices = await _service.getMyServices();
    } catch (_) {
      _myServices = [];
    }
    _isLoadingMine = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> publishService(Map<String, dynamic> data) async {
    try {
      await _service.createService(data);
      await Future.wait([loadServices(), loadMyServices()]);
    } catch (_) {}
  }
}