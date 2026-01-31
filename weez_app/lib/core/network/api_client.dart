import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required this.dio}) {
    // For iOS Simulator, use 'http://127.0.0.1:8080'
    // For Android Emulator, use 'http://10.0.2.2:8080'
    // For Physical Device, use your computer's local IP 'http://192.168.x.x:8080'
    dio.options.baseUrl = 'http://127.0.0.1:8080';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
  }

  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    dio.options.headers.remove('Authorization');
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return dio.post(path, data: data, options: options);
  }

  Future<Response> patch(String path, {dynamic data, Options? options}) async {
    return dio.patch(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data, Options? options}) async {
    return dio.put(path, data: data, options: options);
  }
}
