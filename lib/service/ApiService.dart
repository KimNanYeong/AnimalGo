import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.0.67:8000", // ✅ 서버 기본 주소 설정
        connectTimeout: Duration(seconds: 10), // ✅ 연결 타임아웃 (10초)
        receiveTimeout: Duration(seconds: 10), // ✅ 응답 타임아웃 (10초)
        headers: {"Content-Type": "application/json"}, // ✅ 기본 헤더 설정
      ),
    );
  }

  /// GET 요청 (예: 친구 목록 가져오기)
  Future<Map<String,dynamic>> get(String endpoint, {Map<String, dynamic>? params}) async {
    // bool isLoading = true; // ✅ 로딩 상태

    try {
      Response response = await _dio.get(endpoint, queryParameters: params);
      return response.data;
    } catch (e) {
      throw Exception("GET 요청 실패: $e");
    }
  }

  /// POST 요청 (예: 로그인)
  Future<Map<String,dynamic>> post(String endpoint, {Map<String, dynamic>? data}) async {
    // bool isLoading = true; // ✅ 로딩 상태
    try {
      Response response = await _dio.post(endpoint, data: data);
      print(response);
      return response.data;
    } catch (e) {
      throw Exception("POST 요청 실패: $e");
    }
  }

  /// PUT 요청 (예: 프로필 수정)
  Future<Map<String,dynamic>> put(String endpoint, {Map<String, dynamic>? data}) async {
    // bool isLoading = true; // ✅ 로딩 상태
    try {
      Response response = await _dio.put(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw Exception("PUT 요청 실패: $e");
    }
  }

  /// DELETE 요청 (예: 친구 삭제)
  Future<Response<Map<String,dynamic>>> delete(String endpoint, {Map<String, dynamic>? params}) async {
    // bool isLoading = true; // ✅ 로딩 상태
    try {
      Response response = await _dio.delete(endpoint, queryParameters: params);
      return response.data;
    } catch (e) {
      throw Exception("DELETE 요청 실패: $e");
    }
  }
}
