import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<Either<Failure, List<OrderModel>>> getSellerOrders();
  Future<Either<Failure, OrderModel>> getOrderDetails(String id);
  Future<Either<Failure, void>> updateOrderStatus(String id, String status);

  // Buyer
  Future<Either<Failure, Map<String, dynamic>>> checkout();
  Future<Either<Failure, List<OrderModel>>> getBuyerOrders();
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

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkout() async {
    try {
      final response = await apiClient.post('/checkout');
      // Matches OrderApi.router.post('/checkout', ...) mounted at / (so /checkout) or /api/v1/checkout?
      // Server.dart: ..mount('/', OrderApi().router.call)
      // OrderApi: router.post('/checkout', _checkout) -> /checkout
      // BUT convention is usually /api/v1...
      // Let's check server.dart again.
      // It was mounted at root... wait.
      // OrderApi was mounted at '/'.
      // So path is just `/checkout`.
      // But other APIs are at `/api/v1/...`.
      // I should have mounted OrderApi at `/api/v1`.
      // I'll fix the path in ApiClient call to include /api/v1 if I change server.dart later,
      // OR just rely on current mount.
      // Actually, standard is /api/v1/checkout.
      // I should update server.dart to mount OrderApi at /api/v1 ??
      // BUT Seller is at /seller -> /seller/orders?
      // OrderApi has `/seller/orders`.
      // If mounted at `/`, it is `/seller/orders`.
      // If mounted at `/api/v1`, it becomes `/api/v1/seller/orders`.
      // The frontend currently calls `/seller/orders` (see line 21).
      // So OrderApi IS mounted at `/`? OR ApiClient adds base url?
      // ApiClient baseUrl: http://127.0.0.1:8080.
      // Data Source calls `/seller/orders`.
      // So it expects `http://127.0.0.1:8080/seller/orders`.
      // This implementation in datasource implies OrderApi is mounted at root `/`.
      // OK. So checkout is at `/checkout`.

      if (response.statusCode == 200) {
        return Right(response.data as Map<String, dynamic>);
      } else {
        return Left(ServerFailure(response.data['error'] ?? 'Checkout failed'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderModel>>> getBuyerOrders() async {
    try {
      final response = await apiClient.get('/buyer/orders');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return Right(data.map((e) => OrderModel.fromJson(e)).toList());
      } else {
        return Left(
          ServerFailure(response.data['error'] ?? 'Failed to load orders'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
