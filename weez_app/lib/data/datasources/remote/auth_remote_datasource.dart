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
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? email,
    String? phone,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>> getAddresses();
  Future<Either<Failure, void>> addAddress(
    String title,
    String address,
    bool isDefault,
  );
  Future<Either<Failure, void>> deleteAddress(int id);
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
      final response = await apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) data = json.decode(data);
        final token = data['token'];
        final userData = data['user'];
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
        return Left(ServerFailure(response.data['error'] ?? 'Login failed'));
      }
    } catch (e) {
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
      if (response.statusCode == 200) return login(email, password);
      return Left(
        ServerFailure(response.data['error'] ?? 'Registration failed'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await apiClient.put(
        '/auth/profile',
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );
      if (response.statusCode == 200) return const Right(null);
      return Left(ServerFailure(response.data['error'] ?? 'Update failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAddresses() async {
    try {
      final response = await apiClient.get('/auth/addresses');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is String
            ? json.decode(response.data)
            : response.data;
        return Right(data.map((e) => Map<String, dynamic>.from(e)).toList());
      }
      return Left(
        ServerFailure(response.data['error'] ?? 'Failed to get addresses'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addAddress(
    String title,
    String address,
    bool isDefault,
  ) async {
    try {
      final response = await apiClient.post(
        '/auth/addresses',
        data: {'title': title, 'address': address, 'is_default': isDefault},
      );
      if (response.statusCode == 200) return const Right(null);
      return Left(
        ServerFailure(response.data['error'] ?? 'Failed to add address'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(int id) async {
    try {
      final response = await apiClient.delete('/auth/addresses/$id');
      if (response.statusCode == 200) return const Right(null);
      return Left(
        ServerFailure(response.data['error'] ?? 'Failed to delete address'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
