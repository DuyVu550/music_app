import 'package:dio/dio.dart';
import 'dart:convert';

/// Data source kết nối trực tiếp với iTunes Search API.
/// Trả về dữ liệu thô (Map) để Repository chuyển đổi sang Domain Entity.
/// iTunes API miễn phí, không cần API key và có cung cấp link ảnh & nhạc preview.
class RemoteTrackDataSource {
  final Dio _dio;

  RemoteTrackDataSource()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://itunes.apple.com/',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  Future<List<Map<String, dynamic>>> getTracks({required String term, String? attribute, int limit = 10}) async {
    final response = await _dio.get(
      'search',
      queryParameters: {
        'term': term,
        if (attribute != null) 'attribute': attribute,
        'limit': limit,
        'entity': 'song',
      },
    );

    // iTunes API trả về string dạng JSON hoặc trực tiếp Map tùy vào content-type,
    // dùng Dio thường sẽ tự parse nếu content-type chuẩn.
    // Nếu API trả về string, ta cần parse, nhưng với Dio, map là data.
    var data = response.data;
    if (data is String) {
      data = jsonDecode(data);
    }

    final results = data['results'] as List<dynamic>? ?? [];
    return results.cast<Map<String, dynamic>>();
  }
}
