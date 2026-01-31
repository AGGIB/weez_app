import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/product_repository.dart';

class MockCartRepository implements CartRepository {
  final List<CartItemEntity> _cartItems = [];
  final ProductRepository _productRepository; // To get full product details

  MockCartRepository(this._productRepository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCartItems() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate delay
    return Right(List.from(_cartItems));
  }

  @override
  Future<Either<Failure, void>> addToCart(String productId, int quantity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Check if item exists
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    
    if (index != -1) {
       // Update quantity
       final existingItem = _cartItems[index];
       _cartItems[index] = existingItem.copyWith(quantity: existingItem.quantity + quantity);
    } else {
       // Add new item
       final productResult = await _productRepository.getProductById(productId);
       
       productResult.fold(
         (failure) => null, // Ignore if product not found (shouldn't happen in happy path)
         (product) {
            _cartItems.add(CartItemEntity(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              product: product,
              quantity: quantity,
            ));
         },
       );
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cartItems.removeWhere((item) => item.product.id == productId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateQuantity(String productId, int quantity) async {
     await Future.delayed(const Duration(milliseconds: 300));
     final index = _cartItems.indexWhere((item) => item.product.id == productId);
     if (index != -1) {
       if (quantity <= 0) {
         _cartItems.removeAt(index);
       } else {
         final existingItem = _cartItems[index];
         _cartItems[index] = existingItem.copyWith(quantity: quantity);
       }
     }
     return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    _cartItems.clear();
    return const Right(null);
  }
}
