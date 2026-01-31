import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<Either<Failure, List<OrderModel>>> getSellerOrders();
  Future<Either<Failure, OrderModel>> getOrderDetails(String id);
  Future<Either<Failure, void>> updateOrderStatus(String id, String status);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<OrderModel>>> getSellerOrders() async {
    try {
      final response = await apiClient.get('/seller/orders');
      // Note: OrderApi is mounted at / (root) so path is /seller/orders.
      // Wait, in server.dart: ..mount('/', OrderApi().router)
      // OrderApi: router.get('/seller/orders', ...)
      // So path is indeed /seller/orders.

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return Right(data.map((e) => OrderModel.fromJson(e)).toList());
      } else {
        return Left(
          ServerFailure(response.data['error'] ?? 'Failed to load orders'),
        );
      }
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderModel>> getOrderDetails(String id) async {
    try {
      final response = await apiClient.get('/seller/orders/$id');
      if (response.statusCode == 200) {
        return Right(
          OrderModel.fromJson(response.data as Map<String, dynamic>),
        );
      } else {
        return Left(
          ServerFailure(response.data['error'] ?? 'Failed to load order'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await apiClient.patch(
        '/seller/orders/$id/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response.data['error'] ?? 'Failed to update status'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
