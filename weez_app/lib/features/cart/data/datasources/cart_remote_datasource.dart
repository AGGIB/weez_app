import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/failure.dart';

abstract class CartRemoteDataSource {
  Future<List<dynamic>> getCartItems();
  Future<void> addToCart(int productId, int quantity);
  Future<void> updateQuantity(int itemId, int quantity);
  Future<void> removeFromCart(int itemId);
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient apiClient;

  CartRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> getCartItems() async {
    try {
      final response = await apiClient.get('/cart');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load cart');
    }
  }

  @override
  Future<void> addToCart(int productId, int quantity) async {
    try {
      await apiClient.post(
        '/cart',
        data: {'productId': productId, 'quantity': quantity},
      );
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to add to cart');
    }
  }

  @override
  Future<void> updateQuantity(int itemId, int quantity) async {
    try {
      await apiClient.patch('/cart/$itemId', data: {'quantity': quantity});
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to update cart');
    }
  }

  @override
  Future<void> removeFromCart(int itemId) async {
    try {
      await apiClient.dio.delete('/cart/$itemId');
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to remove from cart');
    }
  }

  @override
  Future<void> clearCart() async {
    // Current backend doesn't have clear cart explicitly exposed except via checkout
    // But we can implement it as loop delete or add endpoint.
    // For now, let's assume valid scope or manual loop.
    // Actually, checking CartApi, I didn't add clearCart.
    // I can stick to individual removal or add it.
    // Let's leave it as TODO or individual for now to match API.
    throw UnimplementedError('Clear cart not implemented in API');
  }
}
