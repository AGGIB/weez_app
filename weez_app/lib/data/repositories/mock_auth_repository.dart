import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _uuid = const Uuid();
  UserEntity? _currentUser;

  final Map<String, UserEntity> _users = {
    'test@test.com': const UserEntity(
      id: '1',
      email: 'test@test.com',
      name: 'Test User',
    ),
  };

  final Map<String, String> _passwords = {'test@test.com': 'password'};

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email) && _passwords[email] == password) {
      _currentUser = _users[email];
      return Right(_currentUser!);
    }
    return const Left(AuthFailure('Invalid email or password'));
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
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email))
      return const Left(AuthFailure('User already exists'));
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
    _currentUser = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    if (_currentUser != null) return Right(_currentUser!);
    return const Left(AuthFailure('Not logged in'));
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAddresses() async {
    return const Right([
      {
        'id': 1,
        'title': 'Дом',
        'address': 'ул. Абая 10, кв 5',
        'is_default': true,
      },
      {
        'id': 2,
        'title': 'Работа',
        'address': 'пр. Достык 210',
        'is_default': false,
      },
    ]);
  }

  @override
  Future<Either<Failure, void>> addAddress(
    String title,
    String address,
    bool isDefault,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAddress(int id) async {
    return const Right(null);
  }
}
