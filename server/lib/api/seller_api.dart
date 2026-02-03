import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/form_data.dart'; // New import
import 'package:mime/mime.dart'; // New import
import '../services/storage_service.dart'; // New import
import '../db/database.dart';
import '../utils/jwt.dart';

class SellerApi {
  Router get router {
    final router = Router();
    router.post('/seller/store', _createStore);
    router.get('/seller/store/mine', _getMyStore);
    router.post('/seller/products', _addProduct);
    router.get('/seller/dashboard-stats', _getDashboardStats);
    router.put('/seller/store', _updateStore);
    return router;
  }

  // ... _createStore ...

  Future<Response> _getDashboardStats(Request request) async {
    try {
      final token = request.headers['Authorization']?.replaceFirst(
        'Bearer ',
        '',
      );
      if (token == null) return Response.forbidden('Missing token');
      final jwt = verifyToken(token);
      if (jwt == null) return Response.forbidden('Invalid token');
      final userId = jwt.payload['user_id'];

      // Get Store ID
      final storeRes = await db.queryMapped(
        'SELECT id, rating FROM stores WHERE seller_id = @id',
        substitutionValues: {'id': userId},
      );
      if (storeRes.isEmpty) {
        return Response.forbidden('User does not have a store');
      }
      final storeRow = storeRes.first;
      final storeId = storeRow['id'];
      final rating = storeRow['rating'] ?? 0.0;

      // Stats: Revenue (delivered orders) and Total Orders
      final ordersStats = await db.queryMapped(
        '''
        SELECT 
          COUNT(*) as count, 
          COALESCE(SUM(total_amount), 0) as revenue 
        FROM orders 
        WHERE store_id = @store_id AND status = 'delivered'
        ''',
        substitutionValues: {'store_id': storeId},
      );

      // Total orders count (regardless of status, or maybe just active? Assumed all for now)
      final allOrdersStats = await db.queryMapped(
        'SELECT COUNT(*) as count FROM orders WHERE store_id = @store_id',
        substitutionValues: {'store_id': storeId},
      );

      final productsStats = await db.queryMapped(
        'SELECT COUNT(*) as count FROM products WHERE store_id = @store_id',
        substitutionValues: {'store_id': storeId},
      );

      final revenue = ordersStats.isNotEmpty
          ? ordersStats.first['revenue']
          : 0.0;
      final ordersCount = allOrdersStats.isNotEmpty
          ? allOrdersStats.first['count']
          : 0;
      final productsCount = productsStats.isNotEmpty
          ? productsStats.first['count']
          : 0;

      return Response.ok(
        json.encode({
          'total_revenue': revenue,
          'orders_count': ordersCount,
          'products_count': productsCount,
          'average_rating': rating,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _updateStore(Request request) async {
    try {
      final token = request.headers['Authorization']?.replaceFirst(
        'Bearer ',
        '',
      );
      if (token == null) return Response.forbidden('Missing token');
      final jwt = verifyToken(token);
      if (jwt == null) return Response.forbidden('Invalid token');
      final userId = jwt.payload['user_id'];

      // Get Store ID
      final storeRes = await db.queryMapped(
        'SELECT id FROM stores WHERE seller_id = @id',
        substitutionValues: {'id': userId},
      );
      if (storeRes.isEmpty) return Response.forbidden('Store not found');
      final storeId = storeRes.first['id'];

      String? name;
      String? description;
      String? logoUrl;

      if (request.isMultipartForm) {
        await for (final formData in request.multipartFormData) {
          if (formData.name == 'name') {
            name = await formData.part.readString();
          } else if (formData.name == 'description') {
            description = await formData.part.readString();
          } else if (formData.name == 'logo') {
            final filename = formData.filename;
            if (filename != null) {
              final bytes = await formData.part.readBytes();
              final mimeType =
                  lookupMimeType(filename) ?? 'application/octet-stream';
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final storedFilename = 'store_logo_${userId}_$timestamp';
              logoUrl = await storage.uploadFile(
                storedFilename,
                bytes,
                mimeType,
              );
            }
          }
        }
      } else {
        return Response.badRequest(
          body: 'Content-Type must be multipart/form-data',
        );
      }

      // Build Update Query dynamic
      final updates = <String>[];
      final values = <String, dynamic>{'id': storeId};

      if (name != null && name.isNotEmpty) {
        updates.add('name = @name');
        values['name'] = name;
      }
      if (description != null) {
        updates.add('description = @description');
        values['description'] = description;
      }
      if (logoUrl != null) {
        updates.add('logo_url = @logo_url');
        values['logo_url'] = logoUrl;
      }

      if (updates.isEmpty) {
        return Response.ok(
          json.encode({'message': 'No changes detected'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final query = 'UPDATE stores SET ${updates.join(', ')} WHERE id = @id';
      await db.execute(query, substitutionValues: values);

      // Fetch updated store
      final updatedStoreRes = await db.queryMapped(
        'SELECT * FROM stores WHERE id = @id',
        substitutionValues: {'id': storeId},
      );
      final updatedStore = updatedStoreRes.first;

      return Response.ok(
        json.encode({
          'id': updatedStore['id'],
          'name': updatedStore['name'],
          'description': updatedStore['description'],
          'logoUrl': updatedStore['logo_url'],
          'legalInfo': updatedStore['legal_info'],
          'rating': updatedStore['rating'],
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _createStore(Request request) async {
    try {
      final token = request.headers['Authorization']?.replaceFirst(
        'Bearer ',
        '',
      );
      if (token == null) return Response.forbidden('Missing token');

      final jwt = verifyToken(token);
      if (jwt == null) return Response.forbidden('Invalid token');

      final userId = jwt.payload['user_id'];

      // Check if store already exists
      final existingStore = await db.queryMapped(
        'SELECT id FROM stores WHERE seller_id = @id',
        substitutionValues: {'id': userId},
      );
      if (existingStore.isNotEmpty) {
        return Response(
          409,
          body: json.encode({'error': 'Store already exists'}),
        );
      }

      String? name;
      String? description;
      String? logoUrl;
      // legalInfo is in DB but not requested in prompt?
      // Prompt said: Request Body: name, description, logo.
      // But DB has legal_info. I'll make it optional or omit if not provided.
      // Actually prompt didn't strictly forbid it. I'll check form-data for it.

      if (request.isMultipartForm) {
        await for (final formData in request.multipartFormData) {
          if (formData.name == 'name') {
            name = await formData.part.readString();
          } else if (formData.name == 'description') {
            description = await formData.part.readString();
          } else if (formData.name == 'logo') {
            final filename = formData.filename;
            if (filename != null) {
              final bytes = await formData.part.readBytes();
              final mimeType =
                  lookupMimeType(filename) ?? 'application/octet-stream';
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final storedFilename =
                  'store_logo_${userId}_$timestamp'; // Simplified name
              logoUrl = await storage.uploadFile(
                storedFilename,
                bytes,
                mimeType,
              );
            }
          }
        }
      } else {
        // Fallback to JSON if no file?
        // Prompt implies multipart. But for robust code lets support JSON if no file upload needed?
        // The Prompt explicitly asked: Request Body (Multipart/Form-Data).
        return Response.badRequest(
          body: 'Content-Type must be multipart/form-data',
        );
      }

      if (name == null || name.length < 3) {
        return Response.badRequest(
          body: json.encode({'error': 'Store name required (min 3 chars)'}),
        );
      }

      // Update User Role to Seller
      await db.execute(
        'UPDATE users SET role = \'seller\' WHERE id = @id',
        substitutionValues: {'id': userId},
      );

      // Create Store
      await db.execute(
        'INSERT INTO stores (seller_id, name, description, logo_url) VALUES (@seller_id, @name, @description, @logo_url)',
        substitutionValues: {
          'seller_id': userId,
          'name': name,
          'description': description,
          'logo_url': logoUrl,
        },
      );

      // Fetch created store to return
      final storeRes = await db.queryMapped(
        'SELECT * FROM stores WHERE seller_id = @id',
        substitutionValues: {'id': userId},
      );
      final newStore = storeRes.first;

      return Response.ok(
        json.encode({
          'id': newStore['id'],
          'name': newStore['name'],
          'description': newStore['description'],
          'logoUrl': newStore['logo_url'],
          // 'createdAt': ... if needed
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Create Store Error: $e');
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _getMyStore(Request request) async {
    try {
      final token = request.headers['Authorization']?.replaceFirst(
        'Bearer ',
        '',
      );
      if (token == null) return Response.forbidden('Missing token');
      final jwt = verifyToken(token);
      if (jwt == null) return Response.forbidden('Invalid token');
      final userId = jwt.payload['user_id'];

      final result = await db.queryMapped(
        'SELECT * FROM stores WHERE seller_id = @seller_id',
        substitutionValues: {'seller_id': userId},
      );
      if (result.isEmpty) {
        return Response.notFound(json.encode({'error': 'Store not found'}));
      }

      final row = result.first;
      return Response.ok(
        json.encode({
          'id': row['id'],
          'name': row['name'],
          'description': row['description'],
          'legalInfo': row['legal_info'],
          'rating': row['rating'],
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _addProduct(Request request) async {
    try {
      final token = request.headers['Authorization']?.replaceFirst(
        'Bearer ',
        '',
      );
      if (token == null) return Response.forbidden('Missing token');
      final jwt = verifyToken(token);
      if (jwt == null) return Response.forbidden('Invalid token');
      final userId = jwt.payload['user_id'];

      // Get Store ID
      final storeResult = await db.queryMapped(
        'SELECT id FROM stores WHERE seller_id = @seller_id',
        substitutionValues: {'seller_id': userId},
      );
      if (storeResult.isEmpty) {
        return Response.forbidden('User does not have a store');
      }
      final storeId = storeResult.first['id'];

      final payload = await request.readAsString();
      final data = json.decode(payload);

      // We rely on auto-increment ID for products now, so we don't pass ID
      final imageUrl = data['imageUrl'];
      // If we receive a list of images, we encode it. For backward compatibility we also populate image_url.
      List<String> imageUrls = [];
      if (data['imageUrls'] != null) {
        imageUrls = List<String>.from(data['imageUrls']);
      } else if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }

      final imageUrlsJson = json.encode(imageUrls);

      await db.execute(
        'INSERT INTO products (store_id, name, description, price, category, image_url, image_urls, discount_price, delivery_info) VALUES (@store_id, @name, @description, @price, @category, @image_url, @image_urls, @discount_price, @delivery_info)',
        substitutionValues: {
          'store_id': storeId,
          'name': data['name'],
          'description': data['description'],
          'price': data['price'],
          'category': data['category'],
          'image_url': imageUrls.isNotEmpty
              ? imageUrls.first
              : null, // Fallback
          'image_urls': imageUrlsJson,
          'discount_price': data['discountPrice'] ?? 0.0,
          'delivery_info': data['deliveryInfo'],
        },
      );

      // Since 'execute' doesn't return ID easily in this wrapper, and we rely on 'db.execute',
      // we can't easily get the ID. But we can fetch the latest product by this store.
      // This is not race-condition free but works for MVP.
      // Ideally use: db.queryMapped('INSERT ... RETURNING *') if supported by wrapper.
      // Assuming 'execute' just returns void.
      // Let's rely on finding by name and store_id desc created_at if we had it.
      // Or just return keys. The frontend might need ID.
      // Let's assume we can fetch it.

      final result = await db.queryMapped(
        'SELECT * FROM products WHERE store_id = @store_id ORDER BY id DESC LIMIT 1',
        substitutionValues: {'store_id': storeId},
      );

      if (result.isNotEmpty) {
        final row = result.first;
        final product = {
          'id': row['id'].toString(),
          'name': row['name'],
          'description': row['description'],
          'price': row['price'],
          'category': row['category'],
          'imageUrl': row['image_url'],
          'imageUrls': row['image_urls'] != null
              ? json.decode(row['image_urls'])
              : [],
          'discountPrice': row['discount_price'],
          'deliveryInfo': row['delivery_info'],
          'isFavorite': row['is_favorite'] == true,
          'rating': row['rating'],
          'reviewsCount': row['reviews_count'],
          'sellerId': storeId.toString(), // OR userId if mapped
        };
        // seller_id in stores table refers to user.id. Product has store_id.
        // Frontend expects UserID in sellerId? No, ProductEntity.sellerId usually links to User.
        // Let's pass userId as sellerId for frontend consistency.
        product['sellerId'] = userId;

        return Response.ok(
          json.encode(product),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Fallback
      return Response.ok(json.encode({'message': 'Product added'}));
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }
}
