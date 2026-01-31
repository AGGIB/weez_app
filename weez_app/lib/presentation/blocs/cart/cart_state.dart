import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';

abstract class CartState extends Equatable {
  const CartState();
  
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;

  const CartLoaded({this.items = const []});

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
