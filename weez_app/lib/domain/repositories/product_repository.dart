import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/product.dart';
import '../entities/product_stats.dart';
import '../entities/review.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? storeId,
    String? search,
    double? minPrice,
    double? maxPrice,
  });
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query);
  Future<Either<Failure, ProductEntity>> getProductById(String id);
  Future<Either<Failure, List<String>>> getCategories();
  Future<Either<Failure, bool>> toggleFavorite(String productId);
  Future<Either<Failure, List<ProductEntity>>> getFavorites();
  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product);
  Future<Either<Failure, ProductStats>> getProductStats(String id);
  Future<Either<Failure, List<Review>>> getProductReviews(String id);
}
