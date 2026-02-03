import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await cartRepository.getCartItems();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (items) => emit(CartLoaded(items: items)),
    );
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    final result = await cartRepository.addToCart(
      event.productId,
      event.quantity,
    );
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) => add(LoadCart()),
    );
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    final result = await cartRepository.removeFromCart(event.cartItemId);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) => add(LoadCart()),
    );
  }

  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantity event,
    Emitter<CartState> emit,
  ) async {
    final result = await cartRepository.updateQuantity(
      event.cartItemId,
      event.quantity,
    );
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) => add(LoadCart()),
    );
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    final result = await cartRepository.clearCart();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) => add(LoadCart()),
    );
  }
}
