import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/repositories/order_repository.dart';
import '../datasources/remote/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getSellerOrders() async {
    return await remoteDataSource.getSellerOrders();
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(String id) async {
    return await remoteDataSource.getOrderDetails(id);
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
    String id,
    String status,
  ) async {
    return await remoteDataSource.updateOrderStatus(id, status);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkout() async {
    return await remoteDataSource.checkout();
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getBuyerOrders() async {
    // RemoteDataSource returns List<OrderModel> which extends OrderEntity
    // But generic type might need explicit mapping or covariance.
    // OrderRepository expects List<OrderEntity>.
    // RemoteDataSource returns Either<Failure, List<OrderModel>>.
    // If OrderModel extends OrderEntity, this should work if cast or mapped.
    // Let's rely on covariance or map.
    // Wait, typical pattern: return await remoteDataSource.getBuyerOrders();
    // works because List<OrderModel> is subtype of List<OrderEntity> ?
    // Dart generics are covariant? Yes usually.
    return await remoteDataSource.getBuyerOrders();
  }
}
