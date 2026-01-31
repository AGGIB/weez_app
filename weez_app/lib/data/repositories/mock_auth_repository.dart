import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _uuid = const Uuid();
  UserEntity? _currentUser;

  // Simple in-memory user store for "registration"
  final Map<String, UserEntity> _users = {
    'test@test.com': const UserEntity(
      id: '1',
      email: 'test@test.com',
      name: 'Test User',
      avatarUrl: null,
    ),
  };

  // Passwords store (insecure, just for mock)
  final Map<String, String> _passwords = {'test@test.com': 'password'};

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate delay

    if (_users.containsKey(email) && _passwords[email] == password) {
      _currentUser = _users[email];
      return Right(_currentUser!);
    } else {
      return const Left(AuthFailure('Неверный email или пароль'));
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
    await Future.delayed(const Duration(milliseconds: 1000));

    if (_users.containsKey(email)) {
      return const Left(
        AuthFailure('Пользователь с таким email уже существует'),
      );
    }

    final newUser = UserEntity(
      id: _uuid.v4(),
      email: email,
      name: name,
      role: role,
    );

    _users[email] = newUser;
    _passwords[email] = password;
    _currentUser = newUser;

    return Right(newUser);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    // In a real app, check shared_prefs token here
    if (_currentUser != null) {
      return Right(_currentUser!);
    } else {
      return const Left(AuthFailure('Not logged in'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (_users.containsKey(email)) {
      return const Right(null);
    } else {
      // For security, usually we don't say if user exists, but for mock debug:
      return const Left(AuthFailure('Пользователь не найден'));
    }
  }
}
