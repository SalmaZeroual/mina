import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

class ApiService {
  static Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse('${AppConstants.apiBaseUrl}$path'), headers: await _headers());
    return _handle(res);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('${AppConstants.apiBaseUrl}$path'), headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(Uri.parse('${AppConstants.apiBaseUrl}$path'), headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  static Future<dynamic> delete(String path) async {
    final res = await http.delete(Uri.parse('${AppConstants.apiBaseUrl}$path'), headers: await _headers());
    return _handle(res);
  }

  static dynamic _handle(http.Response res) {
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(data['message'] ?? 'An error occurred', res.statusCode);
  }
}