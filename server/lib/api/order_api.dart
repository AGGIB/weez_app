import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';
import '../utils/jwt.dart';

class OrderApi {
  Router get router {
    final router = Router();
    router.get('/seller/orders', _getSellerOrders);
    router.get('/seller/orders/<id>', _getSellerOrderDetails);
    router.patch('/seller/orders/<id>/status', _updateOrderStatus);
    return router;
  }

  Future<Response> _getSellerOrders(Request request) async {
    try {
      final token = request.headers['Authorization']?.replaceFirst(
        'Bearer ',
        '',
      );
      if (token == null) return Response.forbidden('Missing token');
      final jwt = verifyToken(token);
      if (jwt == null) return Response.forbidden('Invalid token');
      final userId = jwt.payload['user_id'];

      // Get Store ID for this user
      final storeRes = await db.queryMapped(
        'SELECT id FROM stores WHERE seller_id = @id',
        substitutionValues: {'id': userId},
      );
      if (storeRes.isEmpty) return Response.ok(json.encode([]));
      final storeId = storeRes.first['id'];

      final result = await db.queryMapped(
        'SELECT * FROM orders WHERE store_id = @store_id ORDER BY created_at DESC',
        substitutionValues: {'store_id': storeId},
      );

      final orders = result
          .map(
            (row) => {
              'id': row['id'],
              'totalAmount': row['total_amount'],
              'status': row['status'],
              'createdAt': row['created_at'].toString(),
              'userId': row['user_id'],
            },
          )
          .toList();

      return Response.ok(
        json.encode(orders),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _getSellerOrderDetails(Request request, String id) async {
    try {
      final token = request.headers['Authorization']?.replaceFirst(
        'Bearer ',
        '',
      );
      if (token == null) return Response.forbidden('Missing token');
      final jwt = verifyToken(token);
      if (jwt == null) return Response.forbidden('Invalid token');
      final userId = jwt.payload['user_id'];

      // Get Store ID for this user
      final storeRes = await db.queryMapped(
        'SELECT id FROM stores WHERE seller_id = @id',
        substitutionValues: {'id': userId},
      );
      if (storeRes.isEmpty) return Response.forbidden('Store not found');
      final storeId = storeRes.first['id'];

      // Fetch Order and verify it belongs to store
      final orderRes = await db.queryMapped(
        'SELECT * FROM orders WHERE id = @id AND store_id = @store_id',
        substitutionValues: {'id': int.tryParse(id), 'store_id': storeId},
      );

      if (orderRes.isEmpty) {
        return Response.notFound(json.encode({'error': 'Order not found'}));
      }
      final orderRow = orderRes.first;

      // Fetch Items
      final itemsRes = await db.queryMapped(
        '''
        SELECT oi.*, p.name as product_name, p.image_url as product_image
        FROM order_items oi
        JOIN products p ON oi.product_id = p.id
        WHERE oi.order_id = @order_id
        ''',
        substitutionValues: {'order_id': orderRow['id']},
      );

      // Fetch User (Buyer) info
      final userRes = await db.queryMapped(
        'SELECT name, email, phone, address FROM users WHERE id = @user_id',
        substitutionValues: {'user_id': orderRow['user_id']},
      );
      final userRow = userRes.isNotEmpty ? userRes.first : {};

      final orderDetails = {
        'id': orderRow['id'],
        'totalAmount': orderRow['total_amount'],
        'status': orderRow['status'],
        'createdAt': orderRow['created_at'].toString(),
        'userId': orderRow['user_id'],
        'buyerName': userRow['name'] ?? 'Unknown',
        'buyerPhone': userRow['phone'] ?? '',
        'buyerAddress': userRow['address'] ?? '',
        'items': itemsRes
            .map(
              (item) => {
                'id': item['id'],
                'productId': item['product_id'],
                'productName': item['product_name'],
                'productImage': item['product_image'],
                'quantity': item['quantity'],
                'price': item['price'],
              },
            )
            .toList(),
      };

      return Response.ok(
        json.encode(orderDetails),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _updateOrderStatus(Request request, String id) async {
    try {
      final token = request.headers['Authorization']?.replaceFirst(
        'Bearer ',
        '',
      );
      if (token == null) return Response.forbidden('Missing token');
      final jwt = verifyToken(token);
      if (jwt == null) return Response.forbidden('Invalid token');
      final userId = jwt.payload['user_id'];

      // Get Store ID for this user
      final storeRes = await db.queryMapped(
        'SELECT id FROM stores WHERE seller_id = @id',
        substitutionValues: {'id': userId},
      );
      if (storeRes.isEmpty) return Response.forbidden('Store not found');
      final storeId = storeRes.first['id'];

      // Verify Order belongs to store
      final orderRes = await db.queryMapped(
        'SELECT * FROM orders WHERE id = @id AND store_id = @store_id',
        substitutionValues: {'id': int.tryParse(id), 'store_id': storeId},
      );

      if (orderRes.isEmpty) {
        return Response.notFound(json.encode({'error': 'Order not found'}));
      }

      final payload = await request.readAsString();
      final data = json.decode(payload);
      final newStatus = data['status'];

      final validStatuses = [
        'pending',
        'processing',
        'shipped',
        'delivered',
        'cancelled',
      ];
      if (!validStatuses.contains(newStatus)) {
        return Response.badRequest(
          body: json.encode({'error': 'Invalid status'}),
        );
      }

      // Logic: Cannot cancel if already shipped? (Optional, skipping for now)

      await db.execute(
        'UPDATE orders SET status = @status WHERE id = @id',
        substitutionValues: {'status': newStatus, 'id': int.tryParse(id)},
      );

      print(
        'Notification sent to Buyer: Order #$id is now $newStatus',
      ); // Mock Notification

      return Response.ok(json.encode({'status': 'success'}));
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }
}
