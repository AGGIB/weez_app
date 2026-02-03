import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../domain/entities/cart_item.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCartItems() async {
    try {
      final data = await remoteDataSource.getCartItems();
      final items = data.map((json) {
        final productJson = json['product'];
        return CartItemEntity(
          id: json['id']
              .toString(), // API returns int id, entity expects String
          quantity: json['quantity'] as int,
          product: ProductEntity(
            id: productJson['id'].toString(),
            name: productJson['name'],
            price: (productJson['price'] as num).toDouble(),
            category: productJson['category'],
            imageUrl: productJson['imageUrl'] ?? '',
            description: '', // Not returned by cart API usually
            rating: 0,
            reviewsCount: 0,
            isFavorite: false,
          ),
        );
      }).toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(
    String productId,
    int quantity,
  ) async {
    try {
      await remoteDataSource.addToCart(int.parse(productId), quantity);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String itemId) async {
    try {
      await remoteDataSource.removeFromCart(int.parse(itemId));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuantity(
    String itemId,
    int quantity,
  ) async {
    try {
      await remoteDataSource.updateQuantity(int.parse(itemId), quantity);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      // API unimplemented
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
