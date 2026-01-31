import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItemEntity extends Equatable {
  final String id;
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItemEntity copyWith({
    String? id,
    ProductEntity? product,
    int? quantity,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity];
}
