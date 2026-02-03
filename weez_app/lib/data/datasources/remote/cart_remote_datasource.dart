import '../../../core/network/api_client.dart';
import '../../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addToCart(String productId, int quantity);
  Future<void> removeFromCart(String cartItemId);
  Future<void> updateQuantity(String cartItemId, int quantity);
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient apiClient;

  CartRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final response = await apiClient.get('/cart');
    return (response.data as List)
        .map((json) => CartItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {
    await apiClient.post(
      '/cart',
      data: {'productId': productId, 'quantity': quantity},
    );
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    await apiClient.delete('/cart/$cartItemId');
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await apiClient.patch('/cart/$cartItemId', data: {'quantity': quantity});
  }

  @override
  Future<void> clearCart() async {
    // API doesn't have clearCart yet, maybe loop or add endpoint
    // For now, let's assume we might needs a bulk delete or just it's pending
  }
}
