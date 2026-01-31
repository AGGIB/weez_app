import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    return await remoteDataSource.login(email, password);
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
    return await remoteDataSource.register(
      name,
      email,
      password,
      role,
      storeName: storeName,
      bin: bin,
      address: address,
      phone: phone,
    );
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    // TODO: Implement API/Mock for forgot password
    await Future.delayed(const Duration(seconds: 1));
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    // TODO: Implement /auth/me endpoint in backend and here
    // For now, return failure or mock
    // return Left(const AuthFailure('No user logged in'));

    // TEMPORARY: Return a mock user if we have a token (to avoid blocking flow)
    // In real app, we check stored token -> call API -> return User
    return const Left(AuthFailure('Current user check not implemented'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // remoteDataSource.logout(); // If we had it
    return const Right(null);
  }
}
