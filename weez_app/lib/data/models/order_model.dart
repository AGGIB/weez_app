import '../../domain/entities/order.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.totalAmount,
    required super.status,
    required super.createdAt,
    required super.userId,
    super.buyerName,
    super.buyerPhone,
    super.buyerAddress,
    super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
      buyerName: json['buyerName'],
      buyerPhone: json['buyerPhone'],
      buyerAddress: json['buyerAddress'],
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => OrderItemModel.fromJson(e))
                .toList()
          : null,
    );
  }
}
