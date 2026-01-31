import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../domain/entities/product.dart';
import '../../models/product_model.dart';
import '../../models/product_stats_model.dart';
import '../../models/review_model.dart';

abstract class ProductRemoteDataSource {
  Future<Either<Failure, List<ProductModel>>> getProducts({
    String? category,
    String? storeId,
  });
  Future<Either<Failure, ProductModel>> getProductById(String id);
  Future<Either<Failure, List<String>>> getCategories();
  Future<Either<Failure, ProductModel>> createProduct(ProductEntity product);
  Future<Either<Failure, ProductStatsModel>> getProductStats(String id);
  Future<Either<Failure, List<ReviewModel>>> getProductReviews(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<ProductModel>>> getProducts({
    String? category,
    String? storeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (storeId != null) queryParams['store_id'] = storeId;

      final response = await apiClient.get(
        '/products',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final products = data
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(products);
      } else {
        return Left(
          ServerFailure(response.data['error'] ?? 'Failed to load products'),
        );
      }
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> getProductById(String id) async {
    try {
      final response = await apiClient.get('/products/$id');

      if (response.statusCode == 200) {
        return Right(
          ProductModel.fromJson(response.data as Map<String, dynamic>),
        );
      } else {
        return Left(
          ServerFailure(response.data['error'] ?? 'Product not found'),
        );
      }
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    // Mocking categories for now as backend doesn't have dedicated endpoint yet
    await Future.delayed(const Duration(milliseconds: 100));
    return const Right([
      'Electronics',
      'Computers',
      'Audio',
      'Tablets',
      'Clothing',
    ]);
  }

  @override
  Future<Either<Failure, ProductModel>> createProduct(
    ProductEntity product,
  ) async {
    try {
      final response = await apiClient.post(
        '/seller/products',
        data: {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'imageUrls': product.imageUrls,
          'discountPrice': product.discountPrice,
          'deliveryInfo': product.deliveryInfo,
          'sellerId': product.sellerId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(
          ProductModel.fromJson(response.data as Map<String, dynamic>),
        );
      } else {
        final data = response.data;
        final message = data is Map ? data['error'] : data.toString();
        return Left(ServerFailure(message ?? 'Failed to create product'));
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['error']
          : (data?.toString() ?? e.message);
      return Left(ServerFailure(message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductStatsModel>> getProductStats(String id) async {
    try {
      final response = await apiClient.get('/products/$id/stats');
      if (response.statusCode == 200) {
        return Right(ProductStatsModel.fromJson(response.data));
      } else {
        return Left(
          ServerFailure(response.data['error'] ?? 'Failed to load stats'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewModel>>> getProductReviews(
    String id,
  ) async {
    try {
      final response = await apiClient.get('/products/$id/reviews');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return Right(data.map((e) => ReviewModel.fromJson(e)).toList());
      } else {
        return Left(
          ServerFailure(response.data['error'] ?? 'Failed to load reviews'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
