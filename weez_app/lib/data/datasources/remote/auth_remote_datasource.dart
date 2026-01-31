import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
    String role, {
    String? storeName,
    String? bin,
    String? address,
    String? phone,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      print('Attempting login for $email');
      final response = await apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      print('Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) {
          data = json.decode(data);
        }

        final token = data['token'];
        final userData = data['user'];

        // Save Token (TODO: Use SharedPreferences or SecureStorage)
        apiClient.setToken(token);

        return Right(
          UserEntity(
            id: userData['id'].toString(),
            email: userData['email'],
            name: userData['name'],
            role: userData['role'] ?? 'buyer',
          ),
        );
      } else {
        var data = response.data;
        if (data is String) {
          try {
            data = json.decode(data);
          } catch (_) {}
        }
        final msg = data is Map ? data['error'] : data.toString();
        return Left(ServerFailure(msg ?? 'Login failed'));
      }
    } on DioException catch (e) {
      print('DioError during login: ${e.message}');

      String? errorMessage;
      if (e.response != null) {
        print('DioError Response: ${e.response?.data}');
        var data = e.response!.data;
        if (data is String) {
          try {
            data = json.decode(data);
          } catch (_) {}
        }
        if (data is Map) {
          errorMessage = data['error'];
        }
      }

      return Left(ServerFailure(errorMessage ?? e.message ?? 'Network error'));
    } catch (e) {
      print('General Error during login: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
    String role, {
    String? storeName,
    String? bin,
    String? address,
    String? phone,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'store_name': storeName,
          'bin': bin,
          'address': address,
          'phone': phone,
        },
      );

      if (response.statusCode == 200) {
        // Auto login after register? Or require explicit login.
        // For now, let's just return success or maybe auto-login logic if API returned token.
        // My current API just says "User created". So user needs to login.

        // We'll return a placeholder user or implement logic to login immediately.
        // Let's call login immediately.
        return login(email, password);
      } else {
        var data = response.data;
        if (data is String) {
          try {
            data = json.decode(data);
          } catch (_) {}
        }
        final msg = data is Map ? data['error'] : data.toString();
        return Left(ServerFailure(msg ?? 'Registration failed'));
      }
    } on DioException catch (e) {
      String? errorMessage;
      if (e.response != null) {
        var data = e.response!.data;
        if (data is String) {
          try {
            data = json.decode(data);
          } catch (_) {}
        }
        if (data is Map) {
          errorMessage = data['error'];
        }
      }
      return Left(ServerFailure(errorMessage ?? e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
