import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../models/admin_stats_model.dart';

abstract class AdminRemoteDataSource {
  Future<Either<Failure, AdminStatsModel>> getStats();
  Future<Either<Failure, Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 10,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Either<Failure, AdminStatsModel>> getStats() async {
    try {
      final response = await apiClient.get('/api/v1/admin/stats');
      if (response.statusCode == 200) {
        final data = response.data;
        final map = data is String ? json.decode(data) : data;
        return Right(AdminStatsModel.fromJson(map));
      } else {
        final data = response.data;
        final message = data is Map ? data['error'] : data.toString();
        return Left(ServerFailure(message ?? 'Failed to fetch admin stats'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get(
        '/api/v1/admin/users',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final map = data is String ? json.decode(data) : data;
        return Right(map);
      } else {
        final data = response.data;
        final message = data is Map ? data['error'] : data.toString();
        return Left(ServerFailure(message ?? 'Failed to fetch users'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
