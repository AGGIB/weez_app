import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';

class ProductApi {
  Router get router {
    final router = Router();
    router.get('/', _getAllProducts);
    router.get('/<id>', _getProductById);
    router.get('/<id>/stats', _getProductStats);
    router.get('/<id>/reviews', _getProductReviews);
    return router;
  }

  Future<Response> _getAllProducts(Request request) async {
    try {
      final category = request.url.queryParameters['category'];
      final storeId = request.url.queryParameters['store_id'];

      String sql = 'SELECT * FROM products';
      Map<String, dynamic> params = {};
      List<String> conditions = [];

      if (category != null && category.isNotEmpty) {
        conditions.add('category = @category');
        params['category'] = category;
      }

      if (storeId != null && storeId.isNotEmpty) {
        conditions.add('store_id = @store_id');
        params['store_id'] = int.tryParse(storeId);
      }

      if (conditions.isNotEmpty) {
        sql += ' WHERE ${conditions.join(' AND ')}';
      }

      final result = await db.queryMapped(sql, substitutionValues: params);

      final products = result
          .map((row) {
            try {
              dynamic parseJson(dynamic value) {
                if (value == null) return [];
                if (value is List) return value;
                if (value is String) {
                  try {
                    return json.decode(value);
                  } catch (_) {
                    return [];
                  }
                }
                return [];
              }

              return {
                'id': row['id'].toString(),
                'name': row['name'],
                'description': row['description'],
                'price': row['price'],
                'category': row['category'],
                'imageUrl': row['image_url'],
                'imageUrls': parseJson(row['image_urls']),
                'discountPrice': row['discount_price'],
                'deliveryInfo': row['delivery_info'],
                'isFavorite': row['is_favorite'] == true,
                'rating': row['rating'],
                'reviewsCount': row['reviews_count'],
                'sellerId': row['store_id'],
              };
            } catch (e) {
              print('Error parsing product row: $e');
              return null;
            }
          })
          .where((p) => p != null)
          .cast<Map<String, dynamic>>()
          .toList();

      return Response.ok(
        json.encode(products),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _getProductById(Request request, String idStr) async {
    try {
      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.notFound(json.encode({'error': 'Invalid Product ID'}));
      }

      final result = await db.queryMapped(
        'SELECT * FROM products WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (result.isEmpty) {
        return Response.notFound(json.encode({'error': 'Product not found'}));
      }

      final row = result.first;

      dynamic parseJson(dynamic value) {
        if (value == null) return [];
        if (value is List) return value;
        if (value is String) {
          try {
            return json.decode(value);
          } catch (_) {
            return [];
          }
        }
        return [];
      }

      final product = {
        'id': row['id'].toString(),
        'name': row['name'],
        'description': row['description'],
        'price': row['price'],
        'category': row['category'],
        'imageUrl': row['image_url'],
        'imageUrls': parseJson(row['image_urls']),
        'discountPrice': row['discount_price'],
        'deliveryInfo': row['delivery_info'],
        'isFavorite': row['is_favorite'] == true,
        'rating': row['rating'],
        'reviewsCount': row['reviews_count'],
        'sellerId': row['store_id'],
      };

      return Response.ok(
        json.encode(product),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _getProductStats(Request request, String idStr) async {
    try {
      final id = int.tryParse(idStr);
      if (id == null)
        return Response.notFound(json.encode({'error': 'Invalid ID'}));

      // 1. Sales Count
      final salesRes = await db.queryMapped(
        'SELECT SUM(quantity) as "total" FROM order_items WHERE product_id = @id',
        substitutionValues: {'id': id},
      );
      final sales = (salesRes.first['total'] as num?)?.toInt() ?? 0;

      // 2. Reviews stats
      final productRes = await db.queryMapped(
        'SELECT rating, reviews_count FROM products WHERE id = @id',
        substitutionValues: {'id': id},
      );
      if (productRes.isEmpty)
        return Response.notFound(json.encode({'error': 'Not found'}));

      final rating = productRes.first['rating'];
      final reviewsCount = productRes.first['reviews_count'];

      // Mock views
      final views = (id * 123) % 500 + 50;

      return Response.ok(
        json.encode({
          'sales': sales,
          'rating': rating,
          'reviews': reviewsCount,
          'views': views,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _getProductReviews(Request request, String idStr) async {
    try {
      final id = int.tryParse(idStr);
      if (id == null)
        return Response.notFound(json.encode({'error': 'Invalid ID'}));

      final result = await db.queryMapped(
        '''
        SELECT r.*, u.name as user_name 
        FROM reviews r 
        JOIN users u ON r.user_id = u.id 
        WHERE r.product_id = @id 
        ORDER BY r.created_at DESC
        ''',
        substitutionValues: {'id': id},
      );

      final reviews = result
          .map(
            (row) => {
              'id': row['id'],
              'userName': row['user_name'],
              'rating': row['rating'],
              'comment': row['comment'],
              'createdAt': row['created_at'].toString(),
            },
          )
          .toList();

      return Response.ok(
        json.encode(reviews),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }
}
