import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_stats.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/product_repository.dart';

class MockProductRepository implements ProductRepository {
  final List<ProductEntity> _products = [
    const ProductEntity(
      id: '1',
      name: 'Часы Rolex',
      category: 'Часы',
      price: 1200000,
      rating: 5.0,
      imageUrl: 'https://via.placeholder.com/150',
      description: 'Роскошные швейцарские часы с автоматическим подзаводом.',
      isFavorite: false,
    ),
    const ProductEntity(
      id: '2',
      name: 'iPhone 16 PRO',
      category: 'Телефоны',
      price: 850000,
      rating: 5.0,
      imageUrl: 'https://via.placeholder.com/150',
      description: 'Новейший смартфон от Apple с невероятной камерой.',
      isFavorite: false,
    ),
    const ProductEntity(
      id: '3',
      name: 'MacBook Pro M3',
      category: 'Электроника',
      price: 1450000,
      rating: 4.9,
      imageUrl: 'https://via.placeholder.com/150',
      description: 'Мощный ноутбук для профессионалов.',
      isFavorite: false,
    ),
    const ProductEntity(
      id: '4',
      name: 'AirPods Max',
      category: 'Электроника',
      price: 350000,
      rating: 4.8,
      imageUrl: 'https://via.placeholder.com/150',
      description: 'Беспроводные наушники с активным шумоподавлением.',
      isFavorite: false,
    ),
    const ProductEntity(
      id: '5',
      name: 'Летнее платье',
      category: 'Платья',
      price: 25000,
      rating: 4.5,
      imageUrl: 'https://via.placeholder.com/150',
      description: 'Легкое платье из натурального хлопка.',
      isFavorite: false,
    ),
    const ProductEntity(
      id: '6',
      name: 'Футболка Basic',
      category: 'Футболки',
      price: 12000,
      rating: 4.2,
      imageUrl: 'https://via.placeholder.com/150',
      description: 'Базовая футболка высокого качества.',
      isFavorite: false,
    ),
  ];

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? storeId,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (category != null && category != 'Все товары') {
      return Right(_products.where((p) => p.category == category).toList());
    }
    return Right(_products);
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final product = _products.firstWhere((p) => p.id == id);
      return Right(product);
    } catch (_) {
      return const Left(ServerFailure('Product not found'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String query,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final lowerQuery = query.toLowerCase();
    return Right(
      _products
          .where(
            (p) =>
                p.name.toLowerCase().contains(lowerQuery) ||
                p.category.toLowerCase().contains(lowerQuery),
          )
          .toList(),
    );
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    // Ensure "Все товары" is first
    final categories = {
      'Все товары',
      ..._products.map((p) => p.category),
    }.toList();
    return Right(categories);
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = _products[index];
      // In a real immutable List we'd replace the item, but for mock list modification is fine or copyWith
      // Since _products is final list of consts, we actually need to replace the object in the list
      // But _products is not const, it's final List. Elements are const.
      _products[index] = ProductEntity(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        rating: product.rating,
        isFavorite: !product.isFavorite,
      );
      return Right(_products[index].isFavorite);
    }
    return const Left(ServerFailure('Product not found'));
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(_products.where((p) => p.isFavorite).toList());
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductEntity product,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newProduct = ProductEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: product.name,
      category: product.category,
      price: product.price,
      rating: 0.0,
      imageUrl: product.imageUrl,
      description: product.description,
      isFavorite: false,
      sellerId: product.sellerId,
    );
    _products.add(newProduct);
    return Right(newProduct);
  }

  @override
  Future<Either<Failure, ProductStats>> getProductStats(String id) async {
    return const Right(
      ProductStats(sales: 10, rating: 4.5, reviews: 5, views: 100),
    );
  }

  @override
  Future<Either<Failure, List<Review>>> getProductReviews(String id) async {
    return Right([
      Review(
        id: '1',
        userName: 'Test User',
        rating: 5,
        comment: 'Great product!',
        createdAt: DateTime.now(),
      ),
    ]);
  }
}
