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
}
