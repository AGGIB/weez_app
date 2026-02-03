import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';
import '../utils/jwt.dart';

class CartApi {
  Router get router {
    final router = Router();
    router.get('/cart', _getCart);
    router.post('/cart', _addToCart);
    router.patch('/cart/<id>', _updateCartItem);
    router.delete('/cart/<id>', _removeFromCart);
    return router;
  }

  // Helper to extract user ID from token
  Future<int?> _getUserId(Request request) async {
    final token = request.headers['Authorization']?.replaceFirst('Bearer ', '');
    if (token == null) return null;
    final jwt = verifyToken(token);
    if (jwt == null) return null;
    return jwt.payload['user_id'] as int?;
  }

  Future<Response> _getCart(Request request) async {
    try {
      final userId = await _getUserId(request);
      if (userId == null) return Response.forbidden('Invalid token');

      final result = await db.queryMapped(
        '''
        SELECT ci.id, ci.product_id, ci.quantity, 
               p.name, p.price, p.image_url, p.category
        FROM cart_items ci
        JOIN products p ON ci.product_id = p.id
        WHERE ci.user_id = @user_id
        ORDER BY ci.id ASC
      ''',
        substitutionValues: {'user_id': userId},
      );

      final items = result
          .map(
            (row) => {
              'id': row['id'],
              'productId': row['product_id'],
              'quantity': row['quantity'],
              'product': {
                'id': row['product_id'],
                'name': row['name'],
                'price': row['price'],
                'imageUrl': row['image_url'],
                'category': row['category'],
              },
            },
          )
          .toList();

      return Response.ok(
        json.encode(items),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Get Cart Error: $e');
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _addToCart(Request request) async {
    try {
      final userId = await _getUserId(request);
      if (userId == null) return Response.forbidden('Invalid token');

      final payload = await request.readAsString();
      final data = json.decode(payload);
      final productId = data['productId'];
      final quantity = data['quantity'] ?? 1;

      // Check if item exists
      final check = await db.queryMapped(
        'SELECT id, quantity FROM cart_items WHERE user_id = @uid AND product_id = @pid',
        substitutionValues: {'uid': userId, 'pid': productId},
      );

      if (check.isNotEmpty) {
        // Update quantity
        final newQty = check.first['quantity'] + quantity;
        await db.execute(
          'UPDATE cart_items SET quantity = @qty WHERE id = @id',
          substitutionValues: {'qty': newQty, 'id': check.first['id']},
        );
      } else {
        // Insert
        await db.execute(
          'INSERT INTO cart_items (user_id, product_id, quantity) VALUES (@uid, @pid, @qty)',
          substitutionValues: {
            'uid': userId,
            'pid': productId,
            'qty': quantity,
          },
        );
      }

      return Response.ok(json.encode({'status': 'success'}));
    } catch (e) {
      print('Add to Cart Error: $e');
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _updateCartItem(Request request, String id) async {
    try {
      final userId = await _getUserId(request);
      if (userId == null) return Response.forbidden('Invalid token');

      final payload = await request.readAsString();
      final data = json.decode(payload);
      final quantity = data['quantity'];

      if (quantity == null || quantity < 1) {
        // Optionally delete if quantity is 0? For now just return bad request or handle 0 as delete
        return Response.badRequest(
          body: json.encode({'error': 'Invalid quantity'}),
        );
      }

      await db.execute(
        'UPDATE cart_items SET quantity = @qty WHERE id = @id AND user_id = @uid',
        substitutionValues: {
          'qty': quantity,
          'id': int.parse(id),
          'uid': userId,
        },
      );

      return Response.ok(json.encode({'status': 'success'}));
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _removeFromCart(Request request, String id) async {
    try {
      final userId = await _getUserId(request);
      if (userId == null) return Response.forbidden('Invalid token');

      await db.execute(
        'DELETE FROM cart_items WHERE id = @id AND user_id = @uid',
        substitutionValues: {'id': int.parse(id), 'uid': userId},
      );

      return Response.ok(json.encode({'status': 'success'}));
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }
}
