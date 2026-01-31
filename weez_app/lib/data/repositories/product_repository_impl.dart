import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_stats.dart';
import '../../../domain/entities/review.dart';
import '../../../domain/repositories/product_repository.dart';
import '../datasources/remote/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? storeId,
  }) async {
    return await remoteDataSource.getProducts(
      category: category,
      storeId: storeId,
    );
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    return await remoteDataSource.getProductById(id);
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String query,
  ) async {
    // Basic client-side search or implement new endpoint
    // For now, let's fetch all and filter client side as a simple solution
    final result = await getProducts();
    return result.fold((failure) => Left(failure), (products) {
      final filtered = products
          .where(
            (p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      return Right(filtered);
    });
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String productId) async {
    // TODO: Implement favourite endpoint
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFavorites() async {
    // TODO: Implement favourites endpoint
    return const Right([]);
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductEntity product,
  ) async {
    return await remoteDataSource.createProduct(product);
  }

  @override
  Future<Either<Failure, ProductStats>> getProductStats(String id) async {
    return await remoteDataSource.getProductStats(id);
  }

  @override
  Future<Either<Failure, List<Review>>> getProductReviews(String id) async {
    return await remoteDataSource.getProductReviews(id);
  }
}
