import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';
import '../utils/hash.dart';
import '../utils/jwt.dart';

class AuthApi {
  Router get router {
    final router = Router();
    router.post('/register', _register);
    router.post('/login', _login);
    return router;
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
