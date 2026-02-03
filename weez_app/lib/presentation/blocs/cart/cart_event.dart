import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final String productId;
  final int quantity;

  const AddToCart({required this.productId, this.quantity = 1});

  @override
  List<Object> get props => [productId, quantity];
}

class RemoveFromCart extends CartEvent {
  final String cartItemId;

  const RemoveFromCart(this.cartItemId);

  @override
  List<Object> get props => [cartItemId];
}

class UpdateCartQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;

  const UpdateCartQuantity(this.cartItemId, this.quantity);

  @override
  List<Object> get props => [cartItemId, quantity];
}

class ClearCart extends CartEvent {}
