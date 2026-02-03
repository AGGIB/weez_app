import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
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
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    // This is usually handled by AuthCheckRequested which calls a specific endpoint or checks local token
    // For now, satisfy the interface
    return const Left(
      ServerFailure('Not implemented in repository, use AuthBloc instead'),
    );
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
    return await remoteDataSource.updateProfile(
      name: name,
      email: email,
      phone: phone,
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAddresses() async {
    return await remoteDataSource.getAddresses();
  }

  @override
  Future<Either<Failure, void>> addAddress(
    String title,
    String address,
    bool isDefault,
  ) async {
    return await remoteDataSource.addAddress(title, address, isDefault);
  }

  @override
  Future<Either<Failure, void>> deleteAddress(int id) async {
    return await remoteDataSource.deleteAddress(id);
  }
}
