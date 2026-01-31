import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    productImage,
    quantity,
    price,
  ];
}
