import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../models/store_model.dart';
import '../../models/dashboard_stats_model.dart';

import 'dart:io'; // New import

abstract class SellerRemoteDataSource {
  Future<Either<Failure, StoreModel>> getMyStore();
  Future<Either<Failure, StoreModel>> createStore(
    String name,
    String description,
    File? logo,
  );
  Future<Either<Failure, String>> generateProductDescription(
    String productName,
    String category,
    List<String> keywords,
  );
  Future<Either<Failure, DashboardStatsModel>> getDashboardStats();
  Future<Either<Failure, StoreModel>> updateStore(
    String name,
    String description,
    File? logo,
  );
}

class SellerRemoteDataSourceImpl implements SellerRemoteDataSource {
  final ApiClient apiClient;

  SellerRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Either<Failure, StoreModel>> getMyStore() async {
    try {
      final response = await apiClient.get('/seller/store/mine');

      if (response.statusCode == 200) {
        final data = response.data;
        final map = data is String ? json.decode(data) : data;
        return Right(StoreModel.fromJson(map));
      } else {
        final data = response.data;
        final message = data is Map ? data['error'] : data.toString();
        return Left(ServerFailure(message ?? 'Failed to fetch store'));
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['error']
          : (data?.toString() ?? e.message);
      // Simplify logic for 204 or empty?
      // Actually 404 is handled as error usually.
      return Left(ServerFailure(message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StoreModel>> createStore(
    String name,
    String description,
    File? logo,
  ) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        if (logo != null)
          'logo': await MultipartFile.fromFile(
            logo.path,
            filename: logo.path.split('/').last,
          ),
      });

      final response = await apiClient.post('/seller/store', data: formData);

      if (response.statusCode == 200) {
        final data = response.data;
        final map = data is String ? json.decode(data) : data;
        return Right(StoreModel.fromJson(map));
      } else {
        final data = response.data;
        final message = data is Map ? data['error'] : data.toString();
        return Left(ServerFailure(message ?? 'Failed to create store'));
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['error']
          : (data?.toString() ?? e.message);
      return Left(ServerFailure(message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateProductDescription(
    String productName,
    String category,
    List<String> keywords,
  ) async {
    try {
      final response = await apiClient.post(
        '/ai/generate-description',
        data: {
          'productName': productName,
          'category': category,
          'keywords': keywords,
        },
      );

      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) data = json.decode(data);
        return Right(data['generatedText'] ?? '');
      } else {
        final data = response.data;
        final message = data is Map ? data['error'] : data.toString();
        return Left(ServerFailure(message ?? 'Failed to generate description'));
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['error']
          : (data?.toString() ?? e.message);
      return Left(ServerFailure(message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DashboardStatsModel>> getDashboardStats() async {
    try {
      final response = await apiClient.get('/seller/dashboard-stats');

      if (response.statusCode == 200) {
        final data = response.data;
        final map = data is String ? json.decode(data) : data;
        return Right(DashboardStatsModel.fromJson(map));
      } else {
        final data = response.data;
        final message = data is Map ? data['error'] : data.toString();
        return Left(ServerFailure(message ?? 'Failed to fetch stats'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StoreModel>> updateStore(
    String name,
    String description,
    File? logo,
  ) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        if (logo != null)
          'logo': await MultipartFile.fromFile(
            logo.path,
            filename: logo.path.split('/').last,
          ),
      });

      final response = await apiClient.put('/seller/store', data: formData);

      if (response.statusCode == 200) {
        final data = response.data;
        final map = data is String ? json.decode(data) : data;
        return Right(StoreModel.fromJson(map));
      } else {
        final data = response.data;
        final message = data is Map ? data['error'] : data.toString();
        return Left(ServerFailure(message ?? 'Failed to update store'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
