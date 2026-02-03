import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getSellerOrders();
  Future<Either<Failure, OrderEntity>> getOrderDetails(String id);
  Future<Either<Failure, void>> updateOrderStatus(String id, String status);

  // Buyer
  Future<Either<Failure, Map<String, dynamic>>> checkout();
  Future<Either<Failure, List<OrderEntity>>> getBuyerOrders();
}
