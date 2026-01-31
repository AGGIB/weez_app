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
  final String productId;

  const RemoveFromCart(this.productId);

  @override
  List<Object> get props => [productId];
}

class UpdateCartQuantity extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateCartQuantity(this.productId, this.quantity);

  @override
  List<Object> get props => [productId, quantity];
}

class ClearCart extends CartEvent {}
