import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getCartItems();
  Future<Either<Failure, void>> addToCart(String productId, int quantity);
  Future<Either<Failure, void>> removeFromCart(String cartItemId);
  Future<Either<Failure, void>> updateQuantity(String cartItemId, int quantity);
  Future<Either<Failure, void>> clearCart();
}
