import 'package:equatable/equatable.dart';
import 'order_item.dart';

class OrderEntity extends Equatable {
  final int id;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final int userId;

  final String? buyerName;
  final String? buyerPhone;
  final String? buyerAddress;
  final List<OrderItemEntity>? items;

  const OrderEntity({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.userId,
    this.buyerName,
    this.buyerPhone,
    this.buyerAddress,
    this.items,
  });

  @override
  List<Object?> get props => [
    id,
    totalAmount,
    status,
    createdAt,
    userId,
    buyerName,
    buyerPhone,
    buyerAddress,
    items,
  ];
}
