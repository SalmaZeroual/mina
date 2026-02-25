import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_endpoints.dart';
import 'interceptors/auth_interceptor.dart';
import '../storage/secure_storage.dart';

final apiClientProvider = Provider((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage);
});

class ApiClient {
  late final Dio _dio;

  ApiClient(SecureStorage storage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(AuthInterceptor(storage));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path, {dynamic data}) =>
      _dio.delete(path, data: data);

  Future<Response> postMultipart(
    String path, {
    required String filePath,
    required String fileField,
  }) async {
    final formData = FormData.fromMap({
      fileField: await MultipartFile.fromFile(filePath),
    });
    return _dio.post(path, data: formData);
  }
}