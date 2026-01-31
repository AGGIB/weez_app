import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.quantity,
    required super.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'] ?? 'Unknown',
      productImage: json['productImage'] ?? '',
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
