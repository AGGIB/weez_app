import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

abstract class AiRemoteDataSource {
  Future<String> chat(List<Map<String, String>> messages);
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final ApiClient apiClient;

  AiRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> chat(List<Map<String, String>> messages) async {
    try {
      final response = await apiClient.post(
        '/ai/chat',
        data: {'messages': messages},
      );

      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) data = json.decode(data);
        return data['response'];
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
