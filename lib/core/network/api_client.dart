import 'package:dio/dio.dart';

/// Simple API client used by all data sources.
class ApiClient {
  final Dio _dio;

  ApiClient({BaseOptions? options}) : _dio = Dio(options ?? BaseOptions(baseUrl: 'https://api.example.com'));

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  // Add other HTTP methods as needed (put, delete, etc.)
}
