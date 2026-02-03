import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';
import '../utils/hash.dart';
import '../utils/jwt.dart';

class AuthApi {
  Router get router {
    final router = Router();
    router.post('/auth/register', _register);
    router.post('/auth/login', _login);
    router.put('/auth/profile', _updateProfile);
    router.get('/auth/addresses', _getAddresses);
    router.post('/auth/addresses', _addAddress);
    router.delete('/auth/addresses/<id>', _deleteAddress);
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

  Future<Response> _updateProfile(Request request) async {
    try {
      final userId = await _getUserId(request);
      if (userId == null) return Response.forbidden('Invalid token');

      final payload = await request.readAsString();
      final data = json.decode(payload);
      final name = data['name'];
      final email = data['email'];
      final phone = data['phone'];

      await db.execute(
        'UPDATE users SET name = COALESCE(@name, name), email = COALESCE(@email, email), phone = COALESCE(@phone, phone) WHERE id = @id',
        substitutionValues: {
          'name': name,
          'email': email,
          'phone': phone,
          'id': userId,
        },
      );

      return Response.ok(json.encode({'status': 'success'}));
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _getAddresses(Request request) async {
    try {
      final userId = await _getUserId(request);
      if (userId == null) return Response.forbidden('Invalid token');

      final result = await db.queryMapped(
        'SELECT * FROM user_addresses WHERE user_id = @user_id ORDER BY created_at DESC',
        substitutionValues: {'user_id': userId},
      );

      return Response.ok(
        json.encode(result),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _addAddress(Request request) async {
    try {
      final userId = await _getUserId(request);
      if (userId == null) return Response.forbidden('Invalid token');

      final payload = await request.readAsString();
      final data = json.decode(payload);
      final title = data['title'];
      final address = data['address'];
      final isDefault = data['isDefault'] ?? false;

      if (isDefault == true) {
        await db.execute(
          'UPDATE user_addresses SET is_default = FALSE WHERE user_id = @user_id',
          substitutionValues: {'user_id': userId},
        );
      }

      await db.execute(
        'INSERT INTO user_addresses (user_id, title, address, is_default) VALUES (@uid, @title, @addr, @def)',
        substitutionValues: {
          'uid': userId,
          'title': title,
          'addr': address,
          'def': isDefault,
        },
      );

      return Response.ok(json.encode({'status': 'success'}));
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _deleteAddress(Request request, String id) async {
    try {
      final userId = await _getUserId(request);
      if (userId == null) return Response.forbidden('Invalid token');

      await db.execute(
        'DELETE FROM user_addresses WHERE id = @id AND user_id = @uid',
        substitutionValues: {'id': int.parse(id), 'uid': userId},
      );

      return Response.ok(json.encode({'status': 'success'}));
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _register(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);
      final email = data['email'];
      final password = data['password'];
      final name = data['name'];
      final role = data['role'] ?? 'buyer'; // Default to buyer

      final storeName = data['store_name'];
      final bin = data['bin'];
      final address = data['address'];
      final phone = data['phone'];

      if (email == null || password == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Email and password required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      if (role != 'buyer' && role != 'seller') {
        return Response.badRequest(
          body: json.encode({'error': 'Invalid role'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final hashedPassword = hashPassword(password);

      try {
        await db.execute(
          'INSERT INTO users (email, password_hash, name, role, store_name, bin, address, phone) VALUES (@email, @password_hash, @name, @role, @store_name, @bin, @address, @phone)',
          substitutionValues: {
            'email': email,
            'password_hash': hashedPassword,
            'name': name,
            'role': role,
            'store_name': storeName,
            'bin': bin,
            'address': address,
            'phone': phone,
          },
        );
      } catch (e) {
        // Unique constraint violation usually
        return Response.badRequest(
          body: json.encode({
            'error': 'User already exists or other error: $e',
          }),
        );
      }

      return Response.ok(
        json.encode({'message': 'User created'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _login(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);
      final email = data['email'];
      final password = data['password'];

      final result = await db.queryMapped(
        'SELECT * FROM users WHERE email = @email',
        substitutionValues: {'email': email},
      );

      if (result.isEmpty) {
        return Response.forbidden(
          json.encode({'error': 'Invalid credentials'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final user = result.first;
      if (!verifyPassword(password, user['password_hash'])) {
        return Response.forbidden(
          json.encode({'error': 'Invalid credentials'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final token = generateToken(user['id']);

      return Response.ok(
        json.encode({
          'token': token,
          'user': {
            'id': user['id'],
            'email': user['email'],
            'name': user['name'],
            'role': user['role'],
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }
}
