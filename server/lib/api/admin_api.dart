import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';
import '../utils/jwt.dart';

class AdminApi {
  Router get router {
    final router = Router();
    router.get('/stats', _getStats);
    router.get('/users', _getUsers);
    return router;
  }

  // Actually shelf_router doesn't support per-route middleware easily like this without pipeline.
  // I'll just call a helper check at start of each method for simplicity in this codebase structure.

  Future<void> _verifyAdmin(Request request) async {
    final token = request.headers['Authorization']?.replaceFirst('Bearer ', '');
    if (token == null) throw Exception('Missing token');

    final jwt = verifyToken(token);
    if (jwt == null) throw Exception('Invalid token');

    final userId = jwt.payload['user_id'];
    if (userId == null) {
      throw Exception('Invalid token payload: missing user_id');
    }

    final userIdInt = int.tryParse(userId.toString());
    if (userIdInt == null) {
      throw Exception('Invalid token payload: user_id is not an int');
    }

    final result = await db.queryMapped(
      'SELECT role FROM users WHERE id = @id',
      substitutionValues: {'id': userIdInt},
    );

    if (result.isEmpty || result.first['role'] != 'admin') {
      throw Exception('Access denied');
    }
  }

  Future<Response> _getStats(Request request) async {
    try {
      await _verifyAdmin(request);

      final usersCount = (await db.queryMapped(
        'SELECT COUNT(*) as c FROM users',
      )).first['c'];
      final storesCount = (await db.queryMapped(
        'SELECT COUNT(*) as c FROM stores',
      )).first['c'];
      final ordersCount = (await db.queryMapped(
        'SELECT COUNT(*) as c FROM orders',
      )).first['c'];

      // Revenue from delivered orders
      final revenueRes = await db.queryMapped(
        "SELECT SUM(total_amount) as s FROM orders WHERE status = 'delivered'",
      );
      final revenue = revenueRes.first['s'] ?? 0.0;

      return Response.ok(
        json.encode({
          'total_users': int.tryParse(usersCount.toString()) ?? 0,
          'total_stores': int.tryParse(storesCount.toString()) ?? 0,
          'total_orders': int.tryParse(ordersCount.toString()) ?? 0,
          'platform_revenue': double.tryParse(revenue.toString()) ?? 0.0,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e, stack) {
      print('Admin Stats Error: $e');
      print(stack);
      if (e.toString().contains('Access denied')) {
        return Response.forbidden(json.encode({'error': 'Access denied'}));
      }
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _getUsers(Request request) async {
    try {
      await _verifyAdmin(request);

      final params = request.url.queryParameters;
      final page = int.tryParse(params['page'] ?? '1') ?? 1;
      final limit = int.tryParse(params['limit'] ?? '10') ?? 10;
      final offset = (page - 1) * limit;

      final users = await db.queryMapped(
        'SELECT * FROM users ORDER BY id DESC LIMIT @limit OFFSET @offset',
        substitutionValues: {'limit': limit, 'offset': offset},
      );

      final total = (await db.queryMapped(
        'SELECT COUNT(*) as c FROM users',
      )).first['c'];

      return Response.ok(
        json.encode({
          'data': users
              .map(
                (u) => {
                  ...u,
                  'status': 'active',
                  'created_at':
                      u['created_at']?.toString() ?? DateTime.now().toString(),
                },
              )
              .toList(),
          'meta': {
            'total': int.tryParse(total.toString()) ?? 0,
            'page': page,
            'limit': limit,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e, stack) {
      print('Admin Users Error: $e');
      print(stack);
      if (e.toString().contains('Access denied')) {
        return Response.forbidden(json.encode({'error': 'Access denied'}));
      }
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }
}
